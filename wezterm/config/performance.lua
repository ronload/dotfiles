local M = {}

function M.apply(config)
	config.animation_fps = 60
	config.front_end = "WebGpu"

	return config
end

return M
