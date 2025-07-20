---@diagnostic disable: undefined-type
--[=[ lunar
	about = "creates a game file, publishes it, syncs passes and products"
]=]

local process = require("@lune/process")

local Tag = require("@LuneModules/Tag")
local Mantle = require("@LuneModules/Mantle")
local Assets = require("@LuneModules/Assets")
local InstancesManager = require("@LuneModules/InstancesManager")
local GameManager = require("@LuneModules/GameManager")
local Config = require("@LuneModules/Config")
local Compiler = require("@LuneModules/Compiler")

local args = process.args
local argTag
for _, arg in args do
	if arg == "dev" or arg == "prod" or string.match(arg, "feature_") then
		argTag = arg
		break
	end
end

local tag = Tag.Get() or argTag
local allStartPaths = GameManager.FindAllPaths()

Assets.Sync()
print("Loaded assets")

for _, path in ipairs(allStartPaths) do
	if path == "roblox_packages" then
		continue
	end

	Compiler:Compile(path)
end

print("Compiled src successfully")

for _, place in Config.GetAllPlaces() do
	GameManager.Build(place)
	print("File created")

	InstancesManager.Load(place)
	print("Loaded objects")
end

if Tag.Get() == nil or Tag.Get() == "nil" then
	if tag == nil then
		print("No tag provided. If you want to deploy the game then please provide a tag (dev, prod, feature_*)")
		return
	end

	Tag:Set(tag)
	print("File .env created")

	Mantle.CreateWorkingConfig()
	print("File feature-mantle.toml created")
end

Mantle.Deploy(tag)
local gameLink = Mantle.GetGameLink(tag)
print("Game published. Link: " .. gameLink)

Mantle.SyncMarketing(tag)
print("Passes, products loaded")

Compiler.CompileFile(Config:GetMarketingOutPath())
print("Passes, products compiled")
