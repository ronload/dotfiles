local M = {}

function M.apply(config)
	config.cursor_blink_ease_in = "Constant"
	config.cursor_blink_ease_out = "Constant"
	config.cursor_blink_rate = 500

	config.default_cursor_style = "BlinkingBlock"
	config.enable_scroll_bar = false

	return config
end

return M
