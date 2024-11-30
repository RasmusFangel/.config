return
  {
    {
      "williamboman/mason.nvim",
      opts = {},
    },
    {
      "williamboman/mason-lspconfig.nvim",
      opts = {
        ensure_installed = {
            "lua_ls",
            "bashls",
            "azure_pipelines_ls",
            "dockerls",
            "pyright",
            "ruff",
          }
      },
    },
    {
      "neovim/nvim-lspconfig",
      config = function()
        local lspconfig = require("lspconfig")

        lspconfig.lua_ls.setup({})
        lspconfig.bashls.setup({})
        lspconfig.azure_pipelines_ls.setup({})
        lspconfig.dockerls.setup({})
        lspconfig.pyright.setup({})
        lspconfig.ruff.setup({})

      end,
    }
  }
