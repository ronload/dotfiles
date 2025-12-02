local wezterm = require("wezterm")

local M = {}

function M.setup()
	wezterm.on("gui-startup", function(cmd)
		local screen = wezterm.gui.screens().active
		local ratio = 0.8
		local width, height = screen.width * ratio, screen.height * ratio
		local tab, pane, window = wezterm.mux.spawn_window(cmd or {
			position = {
				x = (screen.width - width) / 2,
				y = (screen.height - height) / 2,
			},
		})
		window:gui_window():set_inner_size(width, height)
	end)

	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		local title = tab.tab_title

		if title and #title > 0 then
			return " " .. title .. " "
		end

		local pane = tab.active_pane
		local pane_title = pane.title

		if pane_title then
			if pane_title:match("nvim") then
				local filename = pane_title:match("([^/]+)%s*$")
				if filename and filename ~= "" then
					filename = filename:gsub("nvim%s*", "")
					return "  " .. filename .. " "
				end
			end
			local cwd = pane.current_working_dir
			if cwd then
				local dir = cwd.file_path:match("([^/]+)/?$")
				if dir and dir ~= "" then
					return "  " .. dir .. " "
				end
			end
		end

		return " " .. tab.tab_index + 1 .. " "
	end)
end

return M
