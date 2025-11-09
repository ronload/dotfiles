local M = {}

function M.apply(config)
	config.color_scheme = "Tokyo Night"
	config.colors = {
		tab_bar = {
			background = "#1a1b26",
			active_tab = {
				bg_color = "#1a1b26",
				fg_color = "#c0caf5",
			},
			inactive_tab = {
				bg_color = "#1a1b26",
				fg_color = "#565f89",
			},
			inactive_tab_hover = {
				bg_color = "#292e42",
				fg_color = "#c0caf5",
			},
			new_tab = {
				bg_color = "#1a1b26",
				fg_color = "#565f89",
			},
			new_tab_hover = {
				bg_color = "#292e42",
				fg_color = "#c0caf5",
			},
		},
	}

	return config
end

return M
