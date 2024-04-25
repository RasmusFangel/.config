local wezterm = require("wezterm")
local config = {}

config.font = wezterm.font("JetBrainsMono Nerd Font Mono", { stretch = "Expanded" })
config.font_size = 14

config.color_scheme = "Catppuccin Mocha"
config.hide_tab_bar_if_only_one_tab = true
-- config.window_decorations = "RESIZE"
-- config.window_background_opacity = 0.94

config.window_padding = {
	left = 2,
	right = 2,
	top = 35,
	bottom = 0,
}
config.enable_scroll_bar = true
config.send_composed_key_when_left_alt_is_pressed = true

return config
