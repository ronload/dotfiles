local wezterm = require("wezterm")
local M = {}

function M.apply(config)
	local font_family = "Menlo"

	config.font_size = 16.0
	config.line_height = 1.618
	config.font = wezterm.font(font_family, {
		weight = "Regular",
	})
	config.font_rules = {
		{
			italic = true,
			intensity = "Normal",
			font = wezterm.font(font_family, { style = "Italic", weight = "Bold" }),
		},
	}

	return config
end

return M
