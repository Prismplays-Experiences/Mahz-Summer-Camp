local fs = require("@lune/fs")
local roblox = require("@lune/roblox")

local Config = require("@LuneModules/Config")
local Compiler = require("@LuneModules/Compiler")

local Terminal = require("@LuneModules/Terminal")

export type GameManager = {
	Build: (place: string?) -> (),
	GetGame: () -> DataModel,
	SetGame: (game: DataModel) -> (),

	_writeNewLockedState: (locked: boolean, place: string?) -> (),
}

local PROJECT = Config:GetOutProjectPath()

local GameManager = {}

function GameManager.AreAllPlacesBuilt(): boolean
	local allPlacesBuilt = true

	for _, place in ipairs(Config.GetAllPlaces()) do
		local gamePath = Config:GetGamePath(place)

		if not fs.isFile(gamePath) then
			allPlacesBuilt = false
		end
	end

	return allPlacesBuilt
end

function GameManager.Build(place: string?)
	local project = Config:GetOutProjectPath(place)
	local game = Config:GetGamePath(place)

	Terminal.execute(`rojo build {project} --output {game}`)
end

function GameManager.GetGame(place: string?)
	local gamePath = Config:GetGamePath(place)
	local placeFile = fs.readFile(gamePath)
	local game = roblox.deserializePlace(placeFile)

	return game
end

function GameManager.SetGame(game, place: string?)
	local gamePath = Config:GetGamePath(place)
	local newPlaceFile = roblox.serializePlace(game, true)

	fs.writeFile(gamePath, newPlaceFile)
end

function GameManager.CopyProjectToOut()
	local projectFile = fs.readFile(PROJECT)
	fs.writeFile(PROJECT, projectFile)
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
	Terminal.execute(`rojo serve {PROJECT}`)
end

function GameManager.Lock(self: GameManager, place: string?)
	self._writeNewLockedState(true, place)
end

function GameManager.Unlock(self: GameManager, place: string?)
	self._writeNewLockedState(false, place)
end

function GameManager._writeNewLockedState(locked: boolean, place: string?)
	local source = "return { \n\tLocked = " .. tostring(locked) .. "\n}"

	local stateFile = Config:GetGameStatusPath(place)
	fs.writeFile(stateFile, source)

	Terminal.execute(`stylua {stateFile}`)
	Compiler.CompileFile(stateFile)
end

return GameManager
