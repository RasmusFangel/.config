local function get_venv()
  if vim.g.LL_VENV_STRING ~= "" then
    return vim.g.LL_VENV_STRING
  end

  return ""
end

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    table.insert(opts.sections.lualine_x, { get_venv })
    opts.theme = "tokyonight"
  end,
}
