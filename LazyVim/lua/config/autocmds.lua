-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local util = require("lspconfig/util")

local path = util.path

local current_cwd = vim.fn.getcwd()

local function split(input, delimiter)
  local arr = {}
  string.gsub(input, "[^" .. delimiter .. "]+", function(w)
    table.insert(arr, w)
  end)
  return arr
end

local function get_project_dir()
  local project_file = vim.fn.findfile("pyproject.toml", vim.api.nvim_buf_get_name(0) .. ";")

  if project_file ~= "" then
    local result = vim.fs.dirname(project_file)
    return result
  end

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

local function set_dap_python()
  local python_path = vim.fn.exepath("python")

  -- BEAM
  table.insert(require("dap").configurations.python, 1, {
    name = "Insights-API",
    type = "python",
    request = "launch",
    module = "uvicorn",
    python = python_path,
    args = {
      "insights_api.app:app",
      -- "--reload",
      "--port 9001",
      "--host 0.0.0.0",
    },
    host = "0.0.0.0",
    port = 9001,
    jinja = true,
    justMyCode = false,
    env = {
      KONG_PAT = vim.fn.trim(
        vim.fn.system("cat " .. "/Users/rasmushansen/Development/boston-cloud/services/insights-api/secrets.txt")
      ),
    },
  })
  table.insert(require("dap").configurations.python, 1, {
    name = "Data-API",
    type = "python",
    request = "launch",
    module = "uvicorn",
    python = python_path,
    args = {
      "data_api.app:app",
      -- "--reload",
      "--port 9000",
      "--host 0.0.0.0",
    },
    host = "0.0.0.0",
    port = 9000,
    jinja = true,
    justMyCode = false,
    env = {
      AWS_PROFILE = "boston-dev",
      DEPLOYMENT_ENVIRONMENT = "LOCAL",
      DOMAIN_NAME_UI = "https://dev.elysia.co",
    },
  })

  -- KINDLET
  table.insert(require("dap").configurations.python, 1, {
    name = "Kindlet | Email-Subscriptions",
    type = "python",
    request = "launch",
    module = "uvicorn",
    python = python_path,
    args = {
      "email_subscriptions.app:app",
      -- "--reload",
      "--port 9000",
      "--host 0.0.0.0",
    },
    host = "0.0.0.0",
    port = 9000,
    jinja = true,
    justMyCode = false,
    env = {
      ENV = "LOCALDEV",
      API_NAME = "Email Subscriptions",
      API_DESCRIPTION = "LOCALDEV",
      API_VERSION = "0.1.0",
      AWS_PROFILE = "kindlet",
      REGION = "eu-west-1",
    },
  })

  table.insert(require("dap").configurations.python, 1, {
    name = "Kindlet | Scraper",
    type = "python",
    request = "launch",
    module = "uvicorn",
    python = python_path,
    args = {
      "scraper.app:app",
      -- "--reload",
      "--port 9000",
      "--host 0.0.0.0",
    },
    host = "0.0.0.0",
    port = 9000,
    jinja = true,
    justMyCode = false,
    env = {
      ENV = "LOCALDEV",
      API_NAME = "Email Subscriptions",
      API_DESCRIPTION = "LOCALDEV",
      API_VERSION = "0.1.0",
      AWS_PROFILE = "kindlet",
      REGION = "eu-west-1",
    },
  })
end

function CheckForPytestCov()
  -- Assume the file we want to check is named 'requirements.txt'
  local file_path = vim.fn.getcwd() .. "/pyproject.toml"

  -- Check if the file exists
  if vim.fn.filereadable(file_path) == 1 then
    -- Read the file content
    local content = vim.fn.readfile(file_path)

    -- Join all lines into a single string for easier searching
    local full_content = table.concat(content, "\n")

    -- Check if 'pytest-cov' is in the content
    if string.find(full_content, "pytest%-cov") then
      return true
      -- Add your desired action here
    else
      return false
      -- Add your desired action here
    end
  else
    -- print("requirements.txt not found in the current working directory")
  end
end

local function set_neotest()
  local args = {}
  local python_path = vim.fn.exepath("python")
  if CheckForPytestCov() == true then
    args = { "--log-level", "DEBUG", "--no-cov" }
  else
    args = { "--log-level", "DEBUG" }
  end

  require("neotest").setup({
    adapters = {
      require("neotest-python")({
        -- Extra arguments for nvim-dap configuration
        -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
        dap = { justMyCode = false },
        -- Command line arguments for runner
        -- Can also be a function to return dynamic values
        args = args,
        -- Runner to use. Will use pytest if available by default.
        -- Can be a function to return dynamic value.
        runner = "pytest",
        pytest = python_path .. " -m pytest",
        -- Custom python path for the runner.
        -- Can be a string or a list of strings.
        -- Can also be a function to return dynamic value.
        -- If not provided, the path will be inferred by checking for
        -- virtual envs in the local directory and for Pipenev/Poetry configs
        python = python_path,
      }),
    },
  })
end

local function set_lspconfig()
  local lsp_config = require("lspconfig")
  -- Pyright
  lsp_config.pyright.setup({
    settings = {
      python = {
        analysis = {
          -- ignore = {"**/tests/**"},
          typeCheckingMode = "strict",
          diagnosticMode = "openFilesOnly",
        },
      },
    },
  })

  vim.g.ACTIVATED_VENV_SYM = ""
end

local function set_lualine(type, venv)
  local params = split(venv, "/")
  if type == "py" then
    -- If using system python
    if string.find(venv, "python3") then
      vim.g.LL_ACTIVATED_VENV = " (" .. params[table.getn(params) - 0] .. ")"
    else
      vim.g.LL_ACTIVATED_VENV = " ( .venv | " .. params[table.getn(params) - 1] .. " )"
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
    -- vim.cmd("cd " .. vim.fn.fnameescape(current_cwd))


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
    local current_file = vim.fn.expand("%:p")
    local project_dir = get_project_dir()
    local cwd = vim.fn.getcwd()

    local venv = path.join(project_dir, ".venv")

    -- Ensure venv is an absolute path
    if not path.is_absolute(venv) then
      venv = path.join(cwd, venv)
    end

    if LAST_ACTIVATED_PATH ~= venv then
      LAST_ACTIVATED_PATH = venv

      if vim.fn.isdirectory(venv) == 1 then
        -- Set environment variables
        vim.fn.setenv("VIRTUAL_ENV", venv)

        -- Update PATH
        local new_path = path.join(venv, "bin") .. ":" .. vim.fn.getenv("PATH")
        vim.fn.setenv("PATH", new_path)

        -- Change directory to project root
        -- local project_root = vim.fn.fnamemodify(venv, ":h")
        -- if vim.fn.isdirectory(project_root) == 1 then
        --   vim.cmd("cd " .. vim.fn.fnameescape(project_root))
        -- end

        set_lspconfig()
        set_neotest()
        set_lualine("py", vim.env.VIRTUAL_ENV)
      end
    end

    -- Debug prints
    -- require("notify")("Final VIRTUAL_ENV: " .. (vim.env.VIRTUAL_ENV or "Not set"))
    -- require("notify")("Final PATH: " .. vim.env.PATH)
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

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Load debug configs on VimEnter",
  pattern = "*.py",
  once = true,
  callback = function()
    set_dap_python()
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "test",
  pattern = "*",
  callback = function()
    vim.diagnostic.config({
      virtual_text = false,
      virtual_lines = { only_current_line = true },
    })
  end,
})

-- vim.api.nvim_create_autocmd("WinEnter", {
--   callback = function()
--     local floating = vim.api.nvim_win_get_config(0).relative ~= ""
--     vim.diagnostic.config({
--       virtual_text = floating,
--       virtual_lines = not floating,
--     })
--   end,
-- })
