-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local util = require("lspconfig/util")

local path = util.path

local function get_python_path()
  -- Find pyproject.toml file - means that it's a python project
  local project_file = vim.fn.findfile("pyproject.toml", vim.api.nvim_buf_get_name(0) .. ";")

  if project_file ~= "" then
    -- Get directory for project
    local project_dir = vim.fs.dirname(project_file)

    -- Use project directory
    local venv = vim.fn.trim(vim.fn.system("poetry --directory " .. project_dir .. " env info -p"))
    return path.join(venv, "bin", "python")
  end

  -- Fallback to system Python.
  return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

LAST_ACTIVATED_PATH = ""

vim.api.nvim_create_autocmd("ExitPre", {
  desc = "Clear env info on leave",
  pattern = "*",
  callback = function()
    LAST_ACTIVATED_PATH = ""
    vim.g.ACTIVATED_VENV = ""
    vim.g.ACTIVATED_VENV_SYM = ""
    vim.g.ACTIVATED_VENV_TYPE = ""
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Update lualine with node env",
  pattern = "*.ts",
  callback = function()
    LAST_ACTIVATED_PATH = "TS"
    vim.g.ACTIVATED_VENV = vim.fn.system('cut -d "=" -f 2 <<< $(npm run env | grep "npm_package_name")')
    vim.g.ACTIVATED_VENV_SYM = "ʦ"
    vim.g.ACTIVATED_VENV_TYPE = "TypeScript"

    require("lualine").refresh()
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Change Python Venv on BufEnter",
  pattern = "*.py",
  callback = function()
    local python_path = get_python_path()
    if LAST_LAST_ACTIVATED_PATH ~= python_path then
      -- LSP CONFIG
      local lsp_config = require("lspconfig")
      -- Pyright
      lsp_config.pyright.setup({
        before_init = function(_, config)
          config.settings.python.pythonPath = python_path
          LAST_LAST_ACTIVATED_PATH = python_path
          vim.g.ACTIVATED_VENV = python_path
          vim.g.ACTIVATED_VENV_SYM = ""
          vim.g.ACTIVATED_VENV_TYPE = "Python"
        end,
      })

      -- LUALINE
      require("lualine").refresh()

      --Neotest
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
