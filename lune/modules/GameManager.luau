local fs = require("@lune/fs")
local roblox = require("@lune/roblox")

local Config = require("@LuneModules/Config")

local Terminal = require("@LuneModules/Terminal")

export type GameManager = {
	Build: () -> (),
	GetGame: () -> DataModel,
	SetGame: (game: DataModel) -> (),
}

local OUT_PATH = Config.GetOutPath()
local PROJECT = Config:GetProjectPath()
local GAME = Config:GetGamePath()

local GameManager = {}

function GameManager.Build()
	Terminal.execute(`rojo build {PROJECT} --output {GAME}`)
end

function GameManager.GetGame()
	local placeFile = fs.readFile(GAME)
	local game = roblox.deserializePlace(placeFile)

	return game
end

function GameManager.SetGame(game)
	local newPlaceFile = roblox.serializePlace(game)
	fs.writeFile(GAME, newPlaceFile)
end

function GameManager.CopyProjectToOut()
	local projectFile = fs.readFile(PROJECT)
	fs.writeFile(OUT_PATH .. "/" .. PROJECT, projectFile)
end

function GameManager.GenerateSourcemap(projectPath: string, outputPath: string?)
	local needsToBeSaved = if not outputPath then false else true

	if not needsToBeSaved then
		outputPath = ""
	end

	Terminal.execute(`rojo sourcemap {projectPath} {if needsToBeSaved then "-o" else ""} {outputPath}`)
end

function GameManager.FindAllPaths()
	local projectFile = fs.readFile(PROJECT)
	local paths = {}

	for path in projectFile:gmatch(`"$path":%s*"(.-)"`) do
		table.insert(paths, path)
	end

	return paths
end

function GameManager.Serve()
	local projectPath = OUT_PATH .. "/" .. PROJECT
	
	Terminal.execute(`rojo serve {projectPath}`)
end

return GameManager
