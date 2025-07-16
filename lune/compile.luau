local process = require("@lune/process")
local task = require("@lune/task")

local Compiler = require("@LuneModules/Compiler")
local GameManager = require("@LuneModules/GameManager")
local PathUtils = require("@LuneModules/PathUtils")
local TableUtils = require("@LuneModules/TableUtils")

local args = process.args
local live = true

for index, arg in pairs(args) do
	if arg == "--live" or arg == "-l" then
		live = if args[index + 1] == "true" then true else false
	end
end

local allStartPaths = GameManager.FindAllPaths()
local allPaths = {}

for _, path in ipairs(allStartPaths) do
	if path == "roblox_packages" then
		continue
	end

	local entries = PathUtils:GetDescendantEntries(path)
	local paths = PathUtils.EntriesToPaths(entries)

	allPaths = TableUtils.Extend(allPaths, paths)
end

if live then
	task.spawn(function()
		PathUtils.Observe(allPaths, function(path)
			Compiler:Compile(path)
		end)
	end)
else
	for _, path in ipairs(allPaths) do
		Compiler:Compile(path)
	end
end

if live == false then
	print("Compiled code successfully")
	return
end

print("Watching for changes...")
print("Started rojo server!")

GameManager.Serve()
