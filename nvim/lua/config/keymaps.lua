-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- WHICH_KEY
local wk = require("which-key")

wk.register({
  T = {
    name = "Terminal",
    t = { "<cmd>:ToggleTerm<cr>", "Toggle Terminal" },
    m = { "<cmd>:Telescope toggleterm_manager<cr>", "Term Manager" },
  },
}, { prefix = "<leader>" })

wk.register({
  fg = { ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", "Live Grep with Args" },
})

wk.register({
  z = { "<cmd>:ZenMode<cr>", "Toggle ZEN mode" },
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

-- TOGGLETERM_MANAGER
local toggleterm_manager = require("toggleterm-manager")
local actions = toggleterm_manager.actions

toggleterm_manager.setup({
  mappings = {
    i = {
      ["<C-p>"] = { action = actions.open_term, exit_on_action = true }, -- toggles terminal open/closed
      ["<C-i>"] = { action = actions.create_term, exit_on_action = false }, -- creates a new terminal buffer
      ["<C-n>"] = { action = actions.create_and_name_term, exit_on_action = false }, -- creates a new terminal buffer
      ["<C-d>"] = { action = actions.delete_term, exit_on_action = false }, -- deletes a terminal buffer
      ["<C-r>"] = { action = actions.rename_term, exit_on_action = false }, -- provides a prompt to rename a terminal
    },
  },
})
