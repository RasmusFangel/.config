local util = require("lspconfig/util")
local path = util.path

local FILES_TO_LOOK_FOR = {
  ["pyproject.toml"] = {
    lang = "python",
    venv_dir = ".venv",
    icon = "",
  },
  ["package.json"] = {
    lang = "javascript",
    venv_dir = ".node_modules",
    icon = "",
  },
  ["rust_at_some_point"] = {
    lang = "rust",
    venv_dir = "",
    icon = "🦀",
  },
}

local function refresh_lualine(env_info)
  local ll_string = ""
  if env_info.lang ~= "" then
    ll_string = env_info.project .. " (" .. env_info.venv_dir .. ")"
  else
    ll_string = ""
  end

  vim.g.LL_VENV_STRING = ll_string

  require("lualine").refresh()
end

local function get_venv_info()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local file_ext = vim.fn.fnamemodify(buf_name, ":e")

  for filename, fileinfo in pairs(FILES_TO_LOOK_FOR) do
    local project_file = vim.fn.findfile(filename, buf_name .. ";")

    if project_file ~= "" then
      local result = vim.fn.fnamemodify(project_file, ":p:h")
      -- require("notify")("Virtual Env Project Dir: " .. result)

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

-- Testing to see if we need this actually.
-- local function refresh_lspconfig(env_info)
--   local python_path_abs = env_info.path .. "/" .. env_info.venv_dir .. "/bin"
--   print(python_path_abs)
--   local lsp_config = require("lspconfig")
--   lsp_config.pyright.setup({
--     root_dir = env_info.path,
--     settings = {
--       pyright = {
--         -- Using Ruff's import organizer
--         disableOrganizeImports = true,
--       },
--       python = {
--         -- pythonPath = python_path_abs,
--         analysis = {
--           -- Ignore all files for analysis to exclusively use Ruff for linting
--           ignore = { "*" },
--         },
--       },
--     },
--   })
-- end

local LAST_ACTIVATED_ENV = ""
local start_path = vim.fn.getenv("PATH")

vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "BufWinEnter" }, {
  desc = "Load debug configs on VimEnter",
  pattern = "*",
  once = false,
  callback = function()
    local env_info = get_venv_info()

    if env_info.lang ~= "" then
      -- if we found env, check if venv has been built
      local venv_abs = env_info.path .. "/" .. env_info.venv_dir
      if vim.fn.isdirectory(venv_abs) == 0 then
        print("No venv found! Please build.")
        return
      end

      if LAST_ACTIVATED_ENV ~= venv_abs then
        print("Last Env: " .. LAST_ACTIVATED_ENV)
        LAST_ACTIVATED_ENV = venv_abs
        -- vim.fn.setenv("VIRTUAL_ENV", venv_abs)

        local new_path = path.join(venv_abs, "bin") .. ":" .. start_path
        -- vim.fn.setenv("PATH", new_path) -- may not need

        -- refresh_lspconfig(env_info) -- may not need
        local python_path_abs = env_info.path .. "/" .. env_info.venv_dir .. "/bin"
        -- print(python_path_abs)
        require("venv-selector").activate_from_path(python_path_abs)
        refresh_lualine(env_info)

        vim.cmd("cd " .. env_info.path)
      end
    end
  end,
})

vim.api.nvim_create_autocmd({ "LspAttach" }, {
  desc = "Load Keybinds for DAP",
  pattern = "*",
  once = true,
  callback = function()
    local dap = require("dap")

    vim.keymap.set("n", "<F5>", function()
      dap.continue()
    end)
    vim.keymap.set("n", "<F6>", function()
      dap.step_over()
    end)
    vim.keymap.set("n", "<F7>", function()
      dap.step_into()
    end)
    vim.keymap.set("n", "<F8>", function()
      dap.step_out()
    end)
    vim.keymap.set("n", "<F9>", function()
      dap.restart()
    end)
    vim.keymap.set("n", "<F10>", function()
      dap.close()
    end)
  end,
})
