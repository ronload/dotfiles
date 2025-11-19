local wezterm = require("wezterm")

local M = {}

function M.apply(config)
	config.keys = {
		-- Vim style window navigations
		{
			key = "h",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivatePaneDirection("Left"),
		},
		{
			key = "j",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivatePaneDirection("Down"),
		},
		{
			key = "k",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivatePaneDirection("Up"),
		},
		{
			key = "l",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivatePaneDirection("Right"),
		},
		{
			key = "Enter",
			mods = "SHIFT",
			action = wezterm.action({ SendString = "\x1b\r" }),
		},
	}
	return config
end

return M
