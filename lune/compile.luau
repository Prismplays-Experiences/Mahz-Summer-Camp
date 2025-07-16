local process = require("@lune/process")

local Compiler = require("@LuneModules/Compiler")
local GameManager = require("@LuneModules/GameManager")
local Config = require("@LuneModules/Config")

local args = process.args
local live = true

for index, arg in pairs(args) do
	if arg == "--live" or arg == "-l" then
		live = if args[index + 1] == "true" then true else false
	end
end

local allPaths = GameManager.FindAllPaths()

table.insert(allPaths, Config.PROJECT)
table.insert(allPaths, "roblox_packages")

for _, path in ipairs(allPaths) do
	if live then
		Compiler:Observe(path)
	else
		Compiler:Compile(path)
	end
end

if live == false then
	print("Compiled code successfully")
	return
end

print("Started rojo server!")

GameManager.Serve()
