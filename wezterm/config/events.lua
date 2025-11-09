local wezterm = require("wezterm")

local M = {}

function M.setup()
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
