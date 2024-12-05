-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.cmd("set guicursor=n-v-c:blinkon1,i:blinkon1-ver25") -- cursor blink, match wezterm
vim.opt.scrolloff = 10 -- How much you see at top/bottom
vim.cmd("let g:gitblame_message_when_not_committed = ''") -- git blame line

-- Don't show virtual line
-- vim.diagnostic.config({
--   virtual_text = false,
--   virtual_lines = { only_current_line = true },
-- })

-- Set the root by a .git file
vim.g.root_spec = { ".git" }
vim.g.LL_VENV_STRING = ""
