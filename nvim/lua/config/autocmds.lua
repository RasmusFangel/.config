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

local function get_python_path_cache()
  -- Find pyproject.toml file - means that it's a python project
  local project_file = vim.fn.findfile("pyproject.toml", vim.api.nvim_buf_get_name(0) .. ";")

  if project_file ~= "" then
    -- Get directory for project
    local project_dir = vim.fs.dirname(project_file)
    local file_name_path = project_dir .. "/.poetryenv"

    -- Use project directory
    if #vim.fn.readfile(file_name_path, "") > 0 then
      local venv = vim.fn.trim(vim.fn.system("cat " .. project_dir .. "/.poetryenv"))
      return venv
    end
  end

  -- Fallback to system Python.
  return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
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

local function get_rust_path()
  -- Find pyproject.toml file - means that it's a python project
  local project_file = vim.fn.findfile("Cargo.toml", vim.api.nvim_buf_get_name(0) .. ";")

  if project_file ~= "" then
    -- Get directory for project
    local project_dir = vim.fs.dirname(project_file)

    return project_dir
  end

  return "undefined"
end

ALREADY_ADDED_TO_DEBUG = {}

local function set_dap_python(python_path)
  local full_buffer_path = vim.fn.expand("%:p")
  if string.find(full_buffer_path, "data-api") ~= "" and ALREADY_ADDED_TO_DEBUG.python_path == nil then
    table.insert(require("dap").configurations.python, {
      name = "Data-API",
      type = "python",
      request = "launch",
      module = "uvicorn",
      python = path.join(python_path, "bin", "python"),
      args = {
        "data_api.app:app",
        -- "--reload",
        "--port 9000",
        "--host 0.0.0.0",
      },
      host = "0.0.0.0",
      port = 9000,
      jinja = true,
      env = {
        AWS_PROFILE = "boston-dev",
        DEPLOYMENT_ENVIRONMENT = "DEV",
        DOMAIN_NAME_UI = "https://dev.elysia.co",
      },
    })
    table.insert(ALREADY_ADDED_TO_DEBUG, python_path)
  end
  if string.find(full_buffer_path, "insights-api") ~= "" and ALREADY_ADDED_TO_DEBUG.python_path == nil then
    table.insert(require("dap").configurations.python, {
      name = "Insights-API",
      type = "python",
      request = "launch",
      module = "uvicorn",
      python = path.join(python_path, "bin", "python"),
      args = {
        "insights_api.app:app",
        -- "--reload",
        "--port 9001",
        "--host 0.0.0.0",
      },
      host = "0.0.0.0",
      port = 9001,
      jinja = true,
      env = {
        AWS_PROFILE = "boston-dev",
        DEPLOYMENT_ENVIRONMENT = "DEV",
        DOMAIN_NAME_UI = "https://dev.elysia.co",
      },
    })
    table.insert(ALREADY_ADDED_TO_DEBUG, python_path)
  end
end

local function set_neotest(python_path)
  python_path = path.join(python_path, "bin", "python")

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
      python_path = path.join(python_path, "bin", "python")
      config.settings.python.pythonPath = python_path
      LAST_ACTIVATED_PATH = python_path
      vim.g.ACTIVATED_VENV = python_path
      vim.g.ACTIVATED_VENV_SYM = ""
    end,
  })
end

local function set_lualine(type, venv)
  venv = path.join(venv, "bin", "python")

  local params = split(venv, "/")
  if type == "py" then
    -- If using system python
    if string.find(venv, "python3") and not string.find(venv, ".venv") then
      vim.g.LL_ACTIVATED_VENV = " (" .. params[table.getn(params) - 0] .. ")"
    else
      vim.g.LL_ACTIVATED_VENV = " (" .. params[table.getn(params) - 2] .. ")"
    end
  end
  if type == "ts" then
    vim.g.LL_ACTIVATED_VENV = "ʦ (" .. params[table.getn(params)] .. " | node_modules)"
  end
  if type == "rs" then
    vim.g.LL_ACTIVATED_VENV = "🦀"
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
  desc = "Change Rust on BufEnter",
  pattern = "*.rs",
  callback = function()
    local rust_path = get_rust_path()
    if LAST_ACTIVATED_PATH ~= rust_path then
      LAST_ACTIVATED_PATH = rust_path
      set_lualine("rs", rust_path)
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Change Node Venv on BufEnter",
  pattern = "*.ts",
  callback = function()
    local node_path = get_node_path()
    if LAST_ACTIVATED_PATH ~= node_path then
      LAST_ACTIVATED_PATH = node_path
      set_lualine("ts", node_path)
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Change Python Venv on BufEnter",
  pattern = "*.py",
  callback = function()
    local python_path = get_python_path_cache()
    if LAST_ACTIVATED_PATH ~= python_path then
      LAST_ACTIVATED_PATH = python_path
      vim.fn.setenv("VIRTUAL_ENV", python_path)
      set_lspconfig(python_path)
      set_neotest(python_path)
      set_dap_python(python_path)
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
