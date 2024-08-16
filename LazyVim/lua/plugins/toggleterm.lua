return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 20,
      direction = "float",
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- Custom function to set the working directory
      local function set_terminal_dir(term)
        if vim.env.VIRTUAL_ENV then
          -- Change to the parent directory of the virtual environment
          local venv_parent = vim.fn.fnamemodify(vim.env.VIRTUAL_ENV, ":h")
          term:change_dir(venv_parent)
          term:send("clear")
        end
      end

      -- Create a custom terminal with the directory setting logic
      local Terminal = require("toggleterm.terminal").Terminal
      local custom_term = Terminal:new({
        on_create = set_terminal_dir,
      })

      -- Function to toggle our custom terminal
      local function toggle_custom_term()
        custom_term:toggle()
      end

      -- Set up a keymap to toggle the custom terminal
      -- vim.keymap.set("n", "<leader>tf", toggle_custom_term, { desc = "Toggle floating terminal" })

      -- WhichKey integration
      local wk = require("which-key")
      wk.register({
        T = { toggle_custom_term, "Toggle floating terminal" },
        -- You can add more terminal-related commands here
      }, { prefix = "<leader>" })
    end,
  },
}
