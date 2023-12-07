-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local util = require("lspconfig/util")

local path = util.path

local function split(input, delimiter)
  local arr = {}
  string.gsub(input, "[^" .. delimiter .. "]+", function(w)
    table.insert(arr, w)
  end)
  return arr
end

MAX_SEARCH_DEPTH = 6

local function get_python_path_2()
  local current_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))

  local current_depth = 0
  local found = false

  while current_depth <= MAX_SEARCH_DEPTH and found == false do
    local project_file = vim.fn.findfile("pyproject.toml", current_dir, 0)

    if project_file ~= "" then
      found = true
    else
      local current_dir_split = split(current_dir, "/")
      table.remove(current_dir_split, table.getn(current_dir_split))
      current_dir = "/" .. table.concat(current_dir_split, "/")
      current_depth = current_depth + 1
    end
  end

  local venv_path = path.join(current_dir, ".venv")

  if vim.fn.isdirectory(venv_path) ~= 0 then
    return path.join(venv_path, "bin", "python")
  else
    return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
  end
end

local function get_node_path()
  -- Find pyproject.toml file - means that it's a python project
  local project_file = vim.fn.findfile("package.json", vim.api.nvim_buf_get_name(0) .. ";")

  if project_file ~= "" then
    -- Get directory for project
    local project_dir = vim.fs.dirname(project_file)

    return project_dir
  end

  return "undefined"
end

local function set_neotest(python_path)
  require("neotest").setup({
    adapters = {
      require("neotest-python")({
        -- Extra arguments for nvim-dap configuration
        -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
        dap = {
          justMyCode = false,
          console = "integratedTerminal",
        },
        python = python_path,
        args = { "--log-level", "DEBUG", "--quiet", "--no-cov" },
        runner = "pytest",
      }),
    },
  })
end

local function set_lspconfig(python_path)
  local lsp_config = require("lspconfig")
  -- Pyright
  lsp_config.pyright.setup({
    before_init = function(_, config)
      config.settings.python.pythonPath = python_path
      LAST_ACTIVATED_PATH = python_path
      vim.g.ACTIVATED_VENV = python_path
      vim.g.ACTIVATED_VENV_SYM = ""
    end,
  })
end

local function set_lualine(type, venv)
  local params = split(venv, "/")
  if type == "py" then
    -- If using system python
    if string.find(venv, "python3") and not string.find(venv, ".venv") then
      vim.g.LL_ACTIVATED_VENV = " (" .. params[table.getn(params) - 0] .. ")"
    else
      vim.g.LL_ACTIVATED_VENV = " (" .. params[table.getn(params) - 3] .. " | .venv)"
    end
  end
  if type == "ts" then
    vim.g.LL_ACTIVATED_VENV = "ʦ (" .. params[table.getn(params)] .. " | node_modules)"
  end

  require("lualine").refresh()
end

LAST_ACTIVATED_PATH = ""

vim.api.nvim_create_autocmd("ExitPre", {
  desc = "Clear env info on leave",
  pattern = "*",
  callback = function()
    LAST_ACTIVATED_PATH = ""
    vim.g.LL_ACTIVATED_VENV = ""
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Change Node Venv on BufEnter",
  pattern = "*.ts",
  callback = function()
    local node_path = get_node_path()
    if LAST_ACTIVATED_PATH ~= node_path then
      set_lualine("ts", node_path)
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Change Python Venv on BufEnter",
  pattern = "*.py",
  callback = function()
    local python_path = get_python_path_2()
    if LAST_ACTIVATED_PATH ~= python_path then
      set_lspconfig(python_path)
      set_neotest(python_path)
      set_lualine("py", python_path)
    end
  end,
})

-- cfn.yaml lint
vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "BufWritePost" }, {
  desc = "Lint CFN files",
  pattern = "*.cfn.yaml",
  callback = function()
    require("lint").try_lint("cfn_lint", { "--non-zero-exit-code none" })
  end,
})
