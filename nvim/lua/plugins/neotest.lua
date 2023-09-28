return {
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/neotest-python" },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            -- Extra arguments for nvim-dap configuration
            -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
            dap = {
              justMyCode = false,
              console = "integratedTerminal",
            },
            python = "shouldn't work",
            args = { "--log-level", "DEBUG", "--quiet", "--no-cov" },
            runner = "pytest",
          }),
        },
      })
    end,
  },
}
