return {
  "akinsho/bufferline.nvim",
  opts = {},
  keys = {
      { "H", "<cmd>:bprev<cr>", desc = "Previous Buffer", mode = "n" },
      { "<leader>bd", "<cmd>:bdelete<cr>", desc = "Delete Buffer", mode = "n" },
      { "L", "<cmd>:bnext<cr>", desc = "Next Buffer", mode = "n" },
  }
}
