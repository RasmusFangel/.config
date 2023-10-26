return {
  "nvimtools/none-ls.nvim",
  optional = true,
  opts = function(_, opts)
    local nls = require("null-ls")
    opts.sources = {
      nls.builtins.formatting.isort.with({
        --prefer_local = ".venv/bin",
        extra_args = {
          "--line-length",
          "120",
        },
      }),
      nls.builtins.diagnostics.mypy.with({
        extra_args = {
          "--ignore-missing-imports",
          "--install-types"
        }
      }),
      nls.builtins.formatting.autoflake,
      nls.builtins.formatting.black.with({
        --prefer_local = ".venv/bin"
        extra_args = {
          "--line-length=120"
        }
      }),
    }
    table.insert(opts.sources, nls.builtins.formatting.black)
  end,
}
