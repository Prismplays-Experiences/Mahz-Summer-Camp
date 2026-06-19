--[=[ lunar
	about = "[DESCRIPTION] Syncs passes, products using Mantle"
]=]

local process = require("@lune/process")

local Mantle = require("@LuneModules/Mantle")
local GameManager = require("@LuneModules/GameManager")
local Tag = require("@LuneModules/Tag")

local args = process.args
local tag = Tag.Get()
local deploy = true
local offline = false
for _, arg in args do
	if arg == "dev" or arg == "prod" or string.match(arg, "feature_") then
		tag = arg
	elseif arg == "--no-deploy" or arg == "-n" then
		deploy = false
	elseif arg == "--offline" or arg == "-o" then
		offline = true
	end
end

if tag == "nil" or offline == true then
	Mantle.SyncInfoOffline()

	if not offline then
		print("Game is not published. Syncing passes and products offline.")
	else
		print("Syncing passes and products offline.")
	end

	return
end

if not GameManager.AreAllPlacesBuilt() then
	print("Not all places are built. Please build all places before publishing")
	return
end

Mantle.CreateWorkingConfig(tag)
print("Mantle config file created")

if deploy then
	Mantle.Deploy(tag)
	local gameLink = Mantle.GetGameLink(tag)
	print("Game published. Link: " .. gameLink)
end

Mantle.SyncInfo(tag)
print("Passes, products loaded")

if tag ~= "nil" and tag ~= nil then
	Tag:Set(tag)
end
