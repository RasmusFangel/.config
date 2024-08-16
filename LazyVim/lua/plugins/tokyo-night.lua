return {
  "folke/tokyonight.nvim",
  opts = {
    style = "moon",
    transparent = true,
    -- terminal_colors = true,
    styles = {
      sidebars = "transparent",
      floats = "transparent",
    },
    on_highlights = function(hl, c)
      hl.DiagnosticVirtualTextError = { fg = c.error, bg = "NONE" }
      hl.DiagnosticVirtualTextWarn = { fg = c.warning, bg = "NONE" }
      hl.DiagnosticVirtualTextInfo = { fg = c.info, bg = "NONE" }
      hl.DiagnosticVirtualTextHint = { fg = c.hint, bg = "NONE" }
    end,
  },
}
