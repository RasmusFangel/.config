local util = require("lspconfig/util")
local path = util.path

local FILES_TO_LOOK_FOR = {
  ["pyproject.toml"] = {
    lang = "python",
    venv_dir = ".venv",
    icon = "",
  },
  ["package.json"] = {
    lang = "javascript",
    venv_dir = "node_modules",
    icon = "",
  },
  ["rust_at_some_point"] = {
    lang = "rust",
    venv_dir = "",
    icon = "🦀",
  },
}

local function get_venv_info()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local file_ext = vim.fn.fnamemodify(buf_name, ":e")

  for filename, fileinfo in pairs(FILES_TO_LOOK_FOR) do
    local project_file = vim.fn.findfile(filename, buf_name .. ";")

    if project_file ~= "" then
      local result = vim.fn.fnamemodify(project_file, ":p:h")

      fileinfo.path = result
      fileinfo.extension = file_ext
      fileinfo.project = vim.fn.fnamemodify(result, ":t")
      return fileinfo
    end
  end

  return {
    lang = "",
    project = "",
    venv_dir = "",
    icon = "",
    path = "",
    extension = file_ext,
  }
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
    print("requirements.txt not found in the current working directory")
  end
end

local function set_neotest(python_path_abs)
  local args = {}
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
        pytest = python_path_abs .. " -m pytest",
        -- Custom python path for the runner.
        -- Can be a string or a list of strings.
        -- Can also be a function to return dynamic value.
        -- If not provided, the path will be inferred by checking for
        -- virtual envs in the local directory and for Pipenev/Poetry configs
        python = python_path_abs,
      }),
    },
  })
end

local function refresh_lspconfig(env_info)
  local lsp_config = require("lspconfig")
  local python_path_abs = path.join(env_info.path, env_info.venv_dir, "bin", "python")

  -- Detach existing Pyright client
  for _, client in ipairs(vim.lsp.get_active_clients({ name = "pyright" })) do
    client.stop()
  end

  -- Setup Pyright with the new configuration
  lsp_config.pyright.setup({
    cmd = { "pyright-langserver", "--stdio" },
    root_dir = env_info.path,
    settings = {
      python = {
        pythonPath = python_path_abs,
        analysis = {
          typeCheckingMode = "strict",
          reportUnusedVariable = "off",
          -- Additional Pyright configuration
        },
      },
    },
    on_attach = function(client, bufnr)
      -- DAP (Debug Adapter Protocol) Keybindings
      local dap = require("dap")
      -- Keymaps for debugging
      vim.keymap.set("n", "<F5>", dap.continue, { buffer = bufnr })
      vim.keymap.set("n", "<F6>", dap.step_over, { buffer = bufnr })
      vim.keymap.set("n", "<F7>", dap.step_into, { buffer = bufnr })
      vim.keymap.set("n", "<F8>", dap.step_out, { buffer = bufnr })
      vim.keymap.set("n", "<F9>", dap.restart, { buffer = bufnr })
      vim.keymap.set("n", "<F10>", dap.close, { buffer = bufnr })

      set_neotest(python_path_abs)
    end,
  })

  -- Load

  -- Manually restart LSP for the current buffer
  vim.cmd("LspRestart pyright")
end

local LAST_ACTIVATED_ENV = ""
vim.g.LL_VENV_STRING = ""
local start_path = vim.fn.getenv("PATH")

local function load_debug_and_lualine(env_info)
  -- Setup Debug Conf
  local debug_conf_abs = path.join(env_info.path, ".vscode", "launch.json")

  local launchjs_check_mark = ""
  -- Check if the file exists and is readable
  if vim.fn.filereadable(debug_conf_abs) == 1 then
    require("dap.ext.vscode").load_launchjs(debug_conf_abs)
    launchjs_check_mark = "✓ "
  end

  -- Set Lualine
  local ll_string = env_info.project .. " | " .. launchjs_check_mark .. env_info.venv_dir

  vim.g.LL_VENV_STRING = ll_string

  require("lualine").refresh()
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  desc = "Dynamically update LSP and environment",
  pattern = "*",
  callback = function()
    local env_info = get_venv_info()

    if env_info.lang ~= "" then
      local venv_abs = path.join(env_info.path, env_info.venv_dir)

      if vim.fn.isdirectory(venv_abs) == 0 and env_info.venv_dir ~= "" then
        print("No venv found! Please build.")
        return
      end

      if LAST_ACTIVATED_ENV ~= venv_abs then
        LAST_ACTIVATED_ENV = venv_abs
        vim.fn.setenv("VIRTUAL_ENV", venv_abs)

        local new_path = path.join(venv_abs, "bin") .. ":" .. start_path
        vim.fn.setenv("PATH", new_path)

        if env_info.lang == "python" then
          refresh_lspconfig(env_info)
        end

        load_debug_and_lualine(env_info)

        vim.cmd("cd " .. env_info.path)
      end
    end
  end,
})
