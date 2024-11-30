return {
  "nvim-treesitter/nvim-treesitter", 
  build = ":TSUpdate",
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
  config = function()
    require("nvim-treesitter.configs").setup({
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "lua", 
        "javascript", 
        "typescript", 
        "python", 
        "bash",
        "markdown",
        "regex",
        "vim",
        "xml",
        "yaml"
      }
    })
  end
}
