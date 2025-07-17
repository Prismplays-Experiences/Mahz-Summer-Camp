--[=[ lunar
	about = "[DESCRIPTION] Compiles src into out using Darklua"
    args = "\n\n[OPTIONAL]\n--one-time/-o if you want to compile code one time without watching for changes"
]=]

local process = require("@lune/process")
local task = require("@lune/task")

local Compiler = require("@LuneModules/Compiler")
local GameManager = require("@LuneModules/GameManager")
local PathUtils = require("@LuneModules/PathUtils")
local TableUtils = require("@LuneModules/TableUtils")

local args = process.args
local live = true

for _, arg in pairs(args) do
	if arg == "--one-time" or arg == "-o" then
		live = false
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

if live == false then
	for _, path in ipairs(allStartPaths) do
		if path == "roblox_packages" then
			continue
		end

		Compiler:Compile(path)
	end

	print("Compiled successfully")
	return
end

task.spawn(function()
	PathUtils.Observe(allPaths, function(path)
		Compiler:Compile(path)
	end)
end)

print("Watching for changes...")
print("Started rojo server!")

GameManager.Serve()
