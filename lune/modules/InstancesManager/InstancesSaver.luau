
local InstancePathUtils = require("@LuneModules/InstancesManager/InstancePathUtils")
local GameManager = require("@LuneModules/GameManager")
local Terminal = require("@LuneModules/Terminal")

local config = require("@LuneModules/Config")
local roblox = require("@lune/roblox")

local pathfs = require("@LunePackages/pathfs")
local fs = pathfs.fs
local Path = pathfs.Path

local REPLICATED_STORAGE_EXCLUDED = InstancePathUtils.GetReplicatedExcludedArray()
local OBJECTS_PATH = Path.new(config.OBJECTS_PATH)

export type InstancesSaver = {
    SaveEverything: (self: InstancesSaver) -> (),

    _saveAsFile: (self: InstancesSaver, instance: Instance, path: pathfs.Path, fileIndex: number?, fileName: string?) -> (),
	_saveAsFolder: (self: InstancesSaver, folder: Instance, path: pathfs.Path, fileIndex: number?) -> pathfs.Path,
    _saveDirectory: (self: InstancesSaver, directoryInstance: Instance, directoryPath: pathfs.Path) -> (),
    _clearSaves: (self: InstancesSaver, path: pathfs.Path) -> (),
    _getFoldersAndNonFoldersFromDirectory: (directoryInstance: Instance) -> {folders: { Folder }, nonFolders: { Instance }},
	_iterateOverInstances: (instances: { Instance }, callback: (instanceName: string, index: number) -> ()) -> (),
}

local InstancesSaver = {}

function InstancesSaver.SaveEverything(self: InstancesSaver)
	local game = GameManager.GetGame()

	Terminal.Out("[][][] STARTED CLEANING EVERYTHING")

	self:_clearSaves(OBJECTS_PATH)

	Terminal.Out("[][][] CLEARED EVERYTHING")

	for pathComponent, service in InstancePathUtils.GetServicesPathsDictionary(game) do
		local servicePath = OBJECTS_PATH:join(pathComponent)

		self:_saveDirectory(service, servicePath)
	end
end

function InstancesSaver._saveDirectory(self: InstancesSaver, directoryInstance: Instance, directoryPath: pathfs.Path)
	local foldersAndNonFolders = self._getFoldersAndNonFoldersFromDirectory(directoryInstance)
	local folders, nonFolders = foldersAndNonFolders.folders, foldersAndNonFolders.nonFolders

	Terminal.Out(`_saveDirectory: {directoryInstance.Name}, {directoryPath:toString():sub(1, 35)}, {#folders} folders, {#nonFolders} nonFolders`)

	self._iterateOverInstances(folders, function(folderName: string, index: number)
		local instance = directoryInstance:FindFirstChild(folderName)

		self:_saveAsFolder(instance, directoryPath, index)

		Terminal.Out("-------------------------------------------")
	end)

	self._iterateOverInstances(nonFolders, function(instanceName: string, index: number)
		local instance = directoryInstance:FindFirstChild(instanceName)

		self:_saveAsFile(instance, directoryPath, index)

		Terminal.Out("-------------------------------------------")
	end)
end

function InstancesSaver._getFoldersAndNonFoldersFromDirectory(directoryInstance: Instance)
    local instancesForSaving = directoryInstance:GetChildren()

    local folders = {}
	local nonFolders = {}

	for _, folder: Folder in pairs(instancesForSaving) do
		local notAFolder = not folder:IsA("Folder")
		local excepted = (directoryInstance.Name == "ReplicatedStorage" and table.find(REPLICATED_STORAGE_EXCLUDED, folder.Name))

		if notAFolder or excepted then
			continue
		end

		table.insert(folders, folder)
	end

	for _, instance: Instance in pairs(instancesForSaving) do
		local isFolder = instance:IsA("Folder")
		local excepted = (directoryInstance.Name == "ReplicatedStorage" and table.find(REPLICATED_STORAGE_EXCLUDED, instance.Name))
		local isCamera = instance.Name == "Camera"

		if isFolder or excepted or isCamera then
			continue
		end

		table.insert(nonFolders, instance)
	end

    return {folders = folders, nonFolders = nonFolders}
end

function InstancesSaver._iterateOverInstances(instances: { Instance }, callback: (instanceName: string, index: number) -> ())
	local instancesCount = {}

	for _, value in ipairs(instances) do
		instancesCount[value.Name] = (instancesCount[value.Name] or 0) + 1
	end

	for instanceName: string, count: number in pairs(instancesCount) do
		for instanceIndex = 1, count do
			local index = if count > 1 then instanceIndex else nil

			callback(instanceName, index)
		end
	end
end

function InstancesSaver._saveAsFolder(self: InstancesSaver, folder: Instance, path: pathfs.Path, fileIndex: number?)
	Terminal.Out(`_saveAsFolder: {folder.Name}, {folder.Parent}, {path:toString():sub(1, 35)}, {tostring(fileIndex)}`)

	local folderName = InstancePathUtils.FixName(folder.Name)
	folderName = if fileIndex == nil then folderName else folderName .. tostring(fileIndex)

	local folderPath: pathfs.Path = path:join(folderName)
	local stringifiedFolderPath = folderPath:toString()

	fs.writeDir(stringifiedFolderPath)
	self:_saveDirectory(folder, folderPath)

	return folderPath
end

function InstancesSaver._saveAsFile(self: InstancesSaver, instance, path: pathfs.Path, fileIndex: number?, fileName: string?)
	if instance:IsA("Folder") or path:fileStem() == "Camera" then
		return
	end

	Terminal.Out(`_saveAsFile: {instance.Name}, {instance.Parent}, {if instance then #instance:GetChildren() else "No children! Instance is nil"}, {path:toString():sub(1, 35)}, {tostring(fileIndex)}, {tostring(fileName)}`)

	if #instance:GetChildren() == 0 or fileName == "init.rbxm" then
		local correctFileName = fileName or ""

		if correctFileName == "" then
			correctFileName = InstancePathUtils.FixName(instance.Name)

			correctFileName = if fileIndex == nil then correctFileName else correctFileName .. tostring(fileIndex)
			correctFileName = correctFileName.. ".rbxm"
		end

		local filePath: pathfs.Path = path:join(correctFileName)
		local stringifiedFilePath = filePath:toString()

		Terminal.Out(`File path: {stringifiedFilePath}`)

		local file = roblox.serializeModel({ instance })
		fs.writeFile(stringifiedFilePath, file)
	else
		local initPath: pathfs.Path = self:_saveAsFolder(instance, path, fileIndex)

		self:_saveAsFile(instance, initPath, nil, "init.rbxm")
	end

	instance:Destroy()
end

function InstancesSaver._clearSaves(self: InstancesSaver, path: pathfs.Path)
	for _, entry in pathfs.getEntries(path) do
		local entryPath = entry.path

		if pathfs.findFile(entryPath) then
			fs.removeFile(entryPath:toString())
		else
			self:_clearSaves(entryPath)
		end
	end
	
	local parentPath: pathfs.Path = path:parent() :: pathfs.Path

	if parentPath:equal(OBJECTS_PATH) or path:equal(OBJECTS_PATH) then
		return
	end

	fs.removeDir(path:toString())
end

return InstancesSaver