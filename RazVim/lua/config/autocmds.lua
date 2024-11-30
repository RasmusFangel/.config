local util = require("lspconfig/util")
local path = util.path

local FILES_TO_LOOK_FOR = {
  ["pyproject.toml"] = {
    lang = "python",
    venv_dir = ".venv",
    icon = ""
  },
  ["package.json"] = {
    lang = "javascript",
    venv_dir = ".node_modules",
    icon = ""
  },
  ["rust_at_some_point"] = {
    lang = "rust",
    venv_dir = "",
    icon = "🦀"
  }
}

local function refresh_lualine(env_info)
  local ll_string = ""
  if env_info.lang ~= "" then
    ll_string = env_info.project .. " | " .. env_info.venv_dir
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
    extension = file_ext
  }
end

local function refresh_lspconfig()
  local lsp_config = require("lspconfig")
  lsp_config.pyright.setup {
  settings = {
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        -- Ignore all files for analysis to exclusively use Ruff for linting
        ignore = { '*' },
      },
    },
  },
}
end

local LAST_ACTIVATED_ENV = ""
local start_path = vim.fn.getenv("PATH")

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Load debug configs on VimEnter",
  pattern = "*",
  once = false,
  callback = function()
    local env_info = get_venv_info()

    if env_info.lang ~= "" then
      -- if we found env, check if venv has been built
      local venv_abs = env_info.path .. "/" .. env_info.venv_dir
      if not vim.fn.isdirectory(venv_abs) then
        require("notify")("No venv found! Please build.")
        return
      end

      if LAST_ACTIVATED_ENV ~= venv_abs then
        LAST_ACTIVATED_ENV = venv_abs
        vim.fn.setenv("VIRTUAL_ENV", venv_abs)

        local new_path = path.join(venv_abs, "bin") .. ":" .. start_path
        vim.fn.setenv("PATH", new_path)
        refresh_lspconfig()
        refresh_lualine(env_info)
      end
    end
  end,
})


vim.api.nvim_create_autocmd('LspAttach', {
  callback = function()
    local wk = require("which-key")

    wk.add({
      { "gd", vim.lsp.buf.definition, desc = "go to definition" },
      { "gi", vim.lsp.buf.implementation, desc = "go to implementation" },
      { "<leader>ca", vim.lsp.buf.code_action, mode = "n", desc = "code actions" },
      { "K", vim.lsp.buf.hover, mode = "n", desc = "Hover" },
    })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end
    if client.name == 'ruff' then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end
  end,
  desc = 'LSP: Disable hover capability from Ruff',
})

