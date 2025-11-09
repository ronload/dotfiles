local fonts = require("config.fonts")
local color = require("config.color")
local window = require("config.window")
local tabbar = require("config.tabbar")
local cursor = require("config.cursor")
local performance = require("config.performance")
local events = require("config.events")
local keybindings = require("config.keybindings")

events.setup()

local config = {}

config = fonts.apply(config)
config = color.apply(config)
config = window.apply(config)
config = tabbar.apply(config)
config = cursor.apply(config)
config = performance.apply(config)
config = keybindings.apply(config)

config.automatically_reload_config = true

return config
