local M = {}

function M.apply(config)
	config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
	config.window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	}
	config.window_background_opacity = 0.95
	config.macos_window_background_blur = 30
	config.window_close_confirmation = "NeverPrompt"

	return config
end

return M
