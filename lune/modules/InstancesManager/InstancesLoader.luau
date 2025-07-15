--!nonstrict
local InstancePathUtils = require("../InstancesManager/InstancePathUtils")
local GameManager = require("@LuneModules/GameManager")

local config = require("@LuneModules/Config")

local pathfs = require("@LunePackages/pathfs")
local Path = pathfs.Path

local fs = pathfs.fs
local roblox = require("@lune/roblox")

local REPLICATED_STORAGE_EXCLUDED = InstancePathUtils.GetReplicatedExcludedArray()
local OBJECTS_PATH = config.OBJECTS_PATH

export type InstancesLoader = {
	LoadEverything: (self: InstancesLoader) -> (),

	_clearDirectoryInstance: (directoryInstance: Instance) -> (),
	_loadSaves: (self: InstancesLoader, parent: Instance, path: pathfs.Path) -> (),
	_loadAsFile: (parent: Instance, path: pathfs.Path) -> (Instance),
	_loadAsFolder: (self: InstancesLoader, parent: Instance, path: pathfs.Path) -> (Instance),

	_game: DataModel?
}

local InstancesLoader = {}
InstancesLoader._game = nil

function InstancesLoader.LoadEverything(self: InstancesLoader)
	self._game = GameManager.GetGame()

	local objectsPath = Path.new(OBJECTS_PATH)
	
	for path, service in InstancePathUtils.GetServicesPathsDictionary(self._game :: DataModel) do
		local servicePath = objectsPath:join(path)

		self._clearDirectoryInstance(service)
		self:_loadSaves(service, servicePath)
	end

	GameManager.SetGame(self._game)
end

function InstancesLoader._clearDirectoryInstance(directoryInstance: Instance)
	for _, child in directoryInstance:GetChildren() do
		if directoryInstance.Name == "ReplicatedStorage" and table.find(REPLICATED_STORAGE_EXCLUDED, child.Name) then
			continue
		end

		child:Destroy()
	end
end

function InstancesLoader._loadSaves(self: InstancesLoader, parent: Instance, path: pathfs.Path)
	if not pathfs.findDir(path) then
		print("[❌] ERROR. didn't find directory by path: " .. path:toString())
	end

	for _, entry in pathfs.getEntries(path) do
		if entry.name == "init.rbxm" then
			continue
		end

		local fullPath = path:join(entry.name)
		local directory: pathfs.Directory? = pathfs.findDir(fullPath)

		if pathfs.findFile(fullPath) then
			self._loadAsFile(parent, fullPath)
		elseif directory then
			self:_loadAsFolder(parent, fullPath)
		end
	end
end

function InstancesLoader._loadAsFile(parent: Instance, path: pathfs.Path)
	local file = fs.readFile(path:toString())
	local instance = roblox.deserializeModel(file)[1]

	if instance:IsA("Camera") then
		return instance
	end

	instance.Parent = parent

	return instance
end

function InstancesLoader._loadAsFolder(self: InstancesLoader, parent: Instance, path: pathfs.Path)
	local instanceName = path:fileName() :: string
	local initPath = path:join("init.rbxm")

	local instance

	if pathfs.findFile(initPath) then
		instance = parent:FindFirstChild(instanceName) or self._loadAsFile(parent, initPath)
	else
		instance = parent:FindFirstChild(instanceName) or roblox.Instance.new("Folder")
	end

	instance.Parent = parent
	instance.Name = instanceName

	self:_loadSaves(instance, path)

	return instance
end

return InstancesLoader
