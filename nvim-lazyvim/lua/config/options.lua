-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- GIT BLAME
vim.cmd("let g:gitblame_message_when_not_committed = ''")

-- Filter diagnostics
local function filter(arr, func)
  -- Filter in place
  -- https://stackoverflow.com/questions/49709998/how-to-filter-a-lua-array-inplace
  local new_index = 1
  local size_orig = #arr
  for old_index, v in ipairs(arr) do
    if func(v, old_index) then
      arr[new_index] = v
      new_index = new_index + 1
    end
  end
  for i = new_index, size_orig do
    arr[i] = nil
  end
end

local function filter_diagnostics(diagnostic)
  local ignored_sources = {
    ["Pyright"] = {
      -- "Expected indented block",
      -- " is not defined",
      " is not accessed",
    },
  }

  local ignored_source = ignored_sources[diagnostic.source]

  if ignored_source == nil then
    return true
  end

  local target = ""

  if diagnostic.message ~= nil then
    target = diagnostic.message
  else
    target = diagnostic.code
  end

  for _, message in ipairs(ignored_source) do
    if string.find(target, message) then
      return false
    end
  end

  return true
end

local function custom_on_publish_diagnostics(a, params, client_id, c, config)
  filter(params.diagnostics, filter_diagnostics)
  vim.lsp.diagnostic.on_publish_diagnostics(a, params, client_id, c, config)
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(custom_on_publish_diagnostics, {})

vim.opt.scrolloff = 10
