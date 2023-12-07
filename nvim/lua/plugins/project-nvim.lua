return {
  "ahmedkhalf/project.nvim",
  opts = {
    manual_mode = true,
    patterns = {
      -- ".git",
      "_darcs",
      -- ".hg",
      ".bzr",
      -- ".svn",
      -- "Makefile",
      "package.json",
      "pyproject.toml",
    },
    silentchdir = false,
    scope_chdir = "global",
  },
  event = "VeryLazy",
  config = function(_, opts)
    require("project_nvim").setup(opts)
    require("lazyvim.util").on_load("telescope.nvim", function()
      require("telescope").load_extension("projects")
    end)
  end,
  keys = {
    { "<leader>fp", "<Cmd>Telescope projects<CR>", desc = "Projects" },
  },
}
