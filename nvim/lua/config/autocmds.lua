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


LAST_PYTHON_PATH = ""

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Test",
  pattern = "*.py",
  callback = function()
    local python_path = get_python_path()
    if LAST_PYTHON_PATH ~= python_path then
      local lsp_config = require("lspconfig")
      lsp_config.pyright.setup({
        before_init = function(_, config)
          config.settings.python.pythonPath = python_path
          LAST_PYTHON_PATH = python_path
          vim.g.POETRY_VENV = python_path
          require('lualine').refresh()

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
      })
    end
  end
})
