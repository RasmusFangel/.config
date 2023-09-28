return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = {
        "isort",
        "autoflake",
        "black",
        "mypy"
      }
    end,
  },
}
