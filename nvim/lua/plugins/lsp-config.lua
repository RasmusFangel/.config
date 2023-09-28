local on_attach = function(client, bufnr)
  -- Disable hover in favor of Pyright
  client.server_capabilities.hoverProvider = false
end


return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.inlay_hints = { enabled = true }
      opts.diagnostics.virtual_text = false
      opts.servers = {
        ruff_lsp = {
          on_attach = on_attach,
        }
      }
    end,
  },
}
