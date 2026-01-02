local wezterm = require("wezterm")

local config = wezterm.config_builder()
config.font_size = 10
config.font = wezterm.font("MesloLGS Nerd Font")
config.color_scheme = "tinted-theming"
config.window_background_opacity = 0.9
config.text_background_opacity = 0.9
config.hide_tab_bar_if_only_one_tab = true

config.mouse_bindings = {
	{
		event = { Down = { streak = 3, button = "Left" } },
		action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
		mods = "NONE",
	},
}

if wezterm.target_triple:find("apple") then
	config.font_size = 14
end

return config
