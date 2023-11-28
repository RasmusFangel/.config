function split(input, delimiter)
  local arr = {}
  string.gsub(input, "[^" .. delimiter .. "]+", function(w)
    table.insert(arr, w)
  end)
  return arr
end

local function get_venv()
  local venv = vim.g.ACTIVATED_VENV
  if venv then
    if vim.g.ACTIVATED_VENV_TYPE == "Python" then
      local params = split(venv, "/")
      return vim.g.ACTIVATED_VENV_SYM .. " (" .. params[table.getn(params) - 2] .. ")"
    elseif vim.g.ACTIVATED_VENV_TYPE == "TypeScript" then
      return vim.g.ACTIVATED_VENV_SYM .. " (" .. venv .. ")"
    end
  else
    return ""
  end

  return ""
end

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    table.insert(opts.sections.lualine_x, { get_venv })
  end,
}
