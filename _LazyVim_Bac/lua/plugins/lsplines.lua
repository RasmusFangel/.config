-- -- Global variable to track the state
-- vim.g.lsp_lines_show_all = false
--
-- -- Function to toggle virtual lines
-- local function toggle_virtual_lines()
--   if vim.g.lsp_lines_show_all then
--     vim.diagnostic.config({ virtual_lines = { only_current_line = true } })
--     vim.g.lsp_lines_show_all = false
--     print("Lsp Lines enabled for current line only.")
--   else
--     vim.diagnostic.config({ virtual_lines = { only_current_line = false } })
--     vim.g.lsp_lines_show_all = true
--     print("Lsp Lines enabled for all lines.")
--   end
-- end

return {
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      require("lsp_lines").setup()
    end,
    -- keys = {
    --   {
    --     "<leader>cL",
    --     function()
    --       toggle_virtual_lines()
    --     end,
    --     desc = "Toggle LSP Lines",
    --   },
    -- },
  },
}
