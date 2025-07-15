local fs = require("@lune/fs")
local roblox = require("@lune/roblox")

local config = require("@LuneModules/Config")

local Terminal = require("@LuneModules/Terminal")

export type GameManager = {
	Build: () -> (),
	GetGame: () -> DataModel,
	SetGame: (game: DataModel) -> (),
}

local GameManager = {}

function GameManager.Build()
	Terminal.execute(`rojo build {config.PROJECT} --output {config.GAME}`)
end

function GameManager.GetGame()
	local placeFile = fs.readFile(config.GAME)
	local game = roblox.deserializePlace(placeFile)

	return game
end

function GameManager.SetGame(game)
	local newPlaceFile = roblox.serializePlace(game)
	fs.writeFile(config.GAME, newPlaceFile)
end

function GameManager.CopyProjectToOut()
	local projectFile = fs.readFile(config.PROJECT)
	fs.writeFile("out/" .. config.PROJECT, projectFile)
end

function GameManager.GenerateSourcemap(projectPath: string, outputPath: string?)
	local needsToBeSaved = if not outputPath then false else true

	if not needsToBeSaved then
		outputPath = ""
	end

	Terminal.execute(`rojo sourcemap {projectPath} {if needsToBeSaved then "-o" else ""} {outputPath}`)
end

return GameManager
