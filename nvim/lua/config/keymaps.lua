-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- WHICH_KEY
local wk = require("which-key")

wk.register({
  T = { "<cmd>:ToggleTerm<cr>", "Toggle Terminal" },
}, { prefix = "<leader>" })

-- DAP
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
