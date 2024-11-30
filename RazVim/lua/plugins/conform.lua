return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      python = { "ruff_format", "ruff_fix" },
      html = { "prettier" },
      xhtml = { "prettier" },
    },
  },
  keys = {
    {"<leader>cf", function(args) require("conform").format({ bufnr=args.buf }) end, desc = "format", mode = "n"}
  }

}
