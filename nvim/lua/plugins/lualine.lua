function split(input, delimiter)
  local arr = {}
  string.gsub(input, '[^' .. delimiter .. ']+', function(w) table.insert(arr, w) end)
  return arr
end

local function get_venv()
  local venv = vim.g.POETRY_VENV
  if venv then
    local params = split(venv, '/')
    return ' (' .. params[table.getn(params) - 2] .. ')'
  else
    return ''
  end
end

return
{
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    table.insert(opts.sections.lualine_x, { get_venv })
  end
}
