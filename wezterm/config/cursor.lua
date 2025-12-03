local M = {}

function M.apply(config)
	config.cursor_blink_ease_in = "EaseIn"
	config.cursor_blink_ease_out = "EaseOut"
	config.cursor_blink_rate = 500

	config.default_cursor_style = "SteadyBlock"
	config.enable_scroll_bar = false

	return config
end

return M
