return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = {
        "pyright",
        "ruff_lsp"
      }
    end
  }
}
