---@diagnostic disable: undefined-type
local process = require("@lune/process")

local config = {}

config.EXEC_OPTIONS = { shell = true, stdio = "default" } :: process.ExecOptions
config.GAME = "game.rbxlx"
config.PROJECT = "MainGame.project.json"
config.SOURCEMAP = "sourcemap.json"
config.OBJECTS_PATH = "objects/MainGame"
config.SRC_PATH = "src"
config.OUT_PATH = "out"
config.PLACES = {"MainGame", "Lobby"}

return config
