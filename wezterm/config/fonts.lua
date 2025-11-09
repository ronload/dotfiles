local wezterm = require("wezterm")

local M = {}

function M.apply(config)
	config.font = wezterm.font("Geist Mono", { weight = "Medium" })
	config.font_size = 16.0
	config.line_height = 1.6

	return config
end

return M
