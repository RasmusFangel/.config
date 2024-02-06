local function get_venv()
  if vim.g.LL_ACTIVATED_VENV ~= "" then
    return vim.g.LL_ACTIVATED_VENV
  end

  return ""
end

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    table.insert(opts.sections.lualine_x, { get_venv })
  end,
}
