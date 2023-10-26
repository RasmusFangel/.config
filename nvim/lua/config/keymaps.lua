-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- WHICH_KEY
local wk = require("which-key")

wk.register({
  d = {
    name = "+debug",
    m = { "<cmd>lua require('neotest').run.run()<cr>", "Method Test" },
    M = { "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", "Method Test [DEBUG]" },
    f = { "<cmd>lua require('neotest').run.run({vim.fn.expand('%')})<cr>", "File Test" },
    F = { "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>", "File Test [DEBUG]" },
    t = { "<cmd>: DapToggleBreakpoint<cr>", "Toggle Breakpoint" },
    u = { "<cmd>lua require('dapui').toggle()<cr>", "Toggle DAP UI" },
  },
  T = { "<cmd>:ToggleTerm<cr>", "Toggle Terminal" },
  L = { "<cmd>lua require('lsp_lines').toggle()<cr>", "LSP Lines toggle" },
  O = { "<cmd>:AerialToggle!<cr>", "Toggle code Outline" },
}, { prefix = "<leader>" })

wk.register({
  g = {
    d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Go to Definition" },
    h = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Hover information" },
    D = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Go to Declaration" },
  },
})

-- DEBUG

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

vim.keymap.set("n", "<C-h>", "<cmd> TmuxNavigateLeft <cr>")
vim.keymap.set("n", "<C-l>", "<cmd> TmuxNavigateRight <cr>")
vim.keymap.set("n", "<C-j>", "<cmd> TmuxNavigateDown <cr>")
vim.keymap.set("n", "<C-k>", "<cmd> TmuxNavigateUp <cr>")
