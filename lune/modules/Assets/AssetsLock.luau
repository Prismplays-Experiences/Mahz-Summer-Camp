local pathfs = require("@LunePackages/PathFS")
local fs = pathfs.fs

local Config = require("@LuneModules/Config")

export type AssetsLock = {
	Save: (self: AssetsLock, tag: string?) -> (),
	Load: (self: AssetsLock, tag: string?) -> (),

	_getSavedLockContent: (tag: string?) -> string,
	_getCurrentLockContent: () -> string,
}

local AssetsLock = {}

function AssetsLock.Save(self: AssetsLock, tag: string?)
	local savePath = Config.GetAssetsLockPath(tag)
	local currentContent = self._getCurrentLockContent()

	fs.writeFile(savePath, currentContent)
end

function AssetsLock.Load(self: AssetsLock, tag: string?)
	local savedContent = self._getSavedLockContent(tag)

	fs.writeFile("asphalt.lock.toml", savedContent)
end

function AssetsLock._getSavedLockContent(tag: string?)
	local savedPath = Config.GetAssetsLockPath(tag)
	local savedContent = fs.readFile(savedPath)

	return savedContent
end

function AssetsLock._getCurrentLockContent()
	local currentContent = fs.readFile("asphalt.lock.toml")

	return currentContent
end

return AssetsLock
