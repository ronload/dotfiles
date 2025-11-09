local M = {}

function M.apply(config) 
	config.window_decorations = "TITLE | RESIZE"
	config.window_padding = {
		left = 15,
		right = 15,
		top = 15,
		bottom = 15,
	}
	config.initial_cols = 150
	config.initial_rows = 25
	config.window_background_opacity = 0.95
	config.macos_window_background_blur = 30

	return config
end

return M
