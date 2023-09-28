return {
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    config = true,
    event = "VeryLazy",
    opts = { name = ".venv", dap_enabled = true, poetry_path = "~/.cache/pypoetry/virtualenvs/" },
  },
}
