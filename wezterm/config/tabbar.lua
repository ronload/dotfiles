local wezterm = require("wezterm")

local M = {}

function M.apply(config)
	config.enable_tab_bar = true
	config.hide_tab_bar_if_only_one_tab = false
	config.use_fancy_tab_bar = false

	config.window_frame = {
		font = wezterm.font("Geist Mono", { weight = "Medium" }),
		font_size = 16.0,
	}

	config.tab_bar_at_bottom = false
	config.tab_max_width = 48

	return config
end

return M
