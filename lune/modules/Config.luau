---@diagnostic disable: undefined-type
local process = require("@lune/process")

local config = {}

config.EXEC_OPTIONS = { shell = true, stdio = "default" } :: process.ExecOptions
config.GAME = "game.rbxlx"
config.PROJECT = "Lobby.project.json"
config.SOURCEMAP = "sourcemap.json"
config.OBJECTS_PATH = "objects/Lobby"
config.SRC_PATH = "src"
config.OUT_PATH = "out"
config.PLACES = {"MainGame", "Lobby"}
config.ENV_VARIABLES = {
	MANTLE_AWS_ACCESS_KEY_ID = "AKIA35J7HFQBK4RXMLGB",
	MANTLE_AWS_SECRET_ACCESS_KEY = "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",
}
config.MARKETING_SCRIPT_PATH = "src/MainGame/ReplicatedStorage/Marketing.luau"

return config
