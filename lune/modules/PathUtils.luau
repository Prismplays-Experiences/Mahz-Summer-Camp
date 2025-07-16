local pathfs = require("@LunePackages/pathfs")
local fs = pathfs.fs
local Path = pathfs.Path

local task = require("@lune/task")

local TableUtils = require("@LuneModules/TableUtils")

local OBSERVE_INTERVAL = 1.75

export type Entry = {
	name: string,
	path: pathfs.Path,
	isFile: boolean,
}

export type PathUtils = {
	GetDescendantEntries: (self: PathUtils, path: pathfs.Path | string) -> { Entry },
	Observe: (paths: { pathfs.Path | string }, callback: (path: pathfs.Path) -> ()) -> (),
	EntriesToPaths: (entries: { Entry }) -> { pathfs.Path },
	_createEntryFromPath: (path: pathfs.Path) -> Entry,
}

local PathUtils = {}

function PathUtils.GetDescendantEntries(self: PathUtils, path: pathfs.Path | string): { Entry }
	if type(path) == "string" then
		path = Path.new(path)
	end

	local directoryPath = path :: pathfs.Path
	local entries = {}

	if fs.isFile(directoryPath:toString()) then
		return entries
	end

	for _, child in ipairs(pathfs.getEntries(directoryPath)) do
		local childEntry = self._createEntryFromPath(child.path)
		local childEntries = self:GetDescendantEntries(child.path)

		table.insert(entries, childEntry)
		entries = TableUtils.Extend(entries, childEntries)
	end

	return entries
end

function PathUtils.EntriesToPaths(entries: { Entry }): { pathfs.Path }
	local paths = {}

	for _, entry in ipairs(entries) do
		table.insert(paths, entry.path)
	end

	return paths
end

function PathUtils.Observe(paths: { pathfs.Path | string }, callback: (path: pathfs.Path) -> (), initialCallback: boolean?)
	initialCallback = initialCallback or false

	local lastModified = {}

	for _, path in paths do
		local entryPath = if type(path) == "string" then Path.new(path) else path

		lastModified[entryPath] = if initialCallback == false then fs.metadata(entryPath).modifiedAt else 0
	end

	while true do
		for path, modified in lastModified do
			local newModified = fs.metadata(path).modifiedAt
            
			if newModified == modified then
				continue
			end

			lastModified[path] = newModified

			task.spawn(function()
				callback(path)
			end)
		end

		task.wait(OBSERVE_INTERVAL)
	end
end

function PathUtils._createEntryFromPath(path: pathfs.Path): Entry
	return {
		name = path:toString(),
		path = path,
		isFile = if fs.isFile(path) then true else false,
	}
end

return PathUtils
