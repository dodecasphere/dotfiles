-- Nerd Font folder glyphs for neo-tree (Ghostty ships the Nerd symbols as a
-- built-in fallback font, so no patched font is needed). Single colour.
local M = {}

M.default_color = "#90a4ae"
M.folder_closed = "󰉋"
M.folder_open = "󰝰"

function M.icon_for(_, opened)
  local glyph = opened and M.folder_open or M.folder_closed
  return glyph, M.default_color
end

return M
