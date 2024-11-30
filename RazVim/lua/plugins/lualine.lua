local function get_venv()
  if vim.g.LL_VENV_STRING ~= "" then
    return vim.g.LL_VENV_STRING
  end

  return ""
end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    sections = {
      lualine_x = {'encoding', 'fileformat', 'filetype', {
      function()
        if vim.g.LL_VENV_STRING ~= "" then
          return vim.g.LL_VENV_STRING
        end

        return ""

      end
    }},
    }
  }
}
