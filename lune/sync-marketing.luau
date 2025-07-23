--[=[ lunar
	about = "[DESCRIPTION] Syncs passes, products using Mantle"
]=]

local process = require("@lune/process")

local Mantle = require("@LuneModules/Mantle")
local GameManager = require("@LuneModules/GameManager")
local Tag = require("@LuneModules/Tag")

local args = process.args
local tag = Tag.Get()
for _, arg in args do
	if arg == "dev" or arg == "prod" or string.match(arg, "feature_") then
		tag = arg
		break
	end
end

if tag == "nil" then
	Mantle.SyncMarketingOffline()
	print("Game is not published. Syncing passes and products offline.")

	return
end

if not GameManager.AreAllPlacesBuilt() then
	print("Not all places are built. Please build all places before publishing")
	return
end

Mantle.CreateWorkingConfig(tag)
print("Mantle config file created")

Mantle.Deploy(tag)
local gameLink = Mantle.GetGameLink(tag)
print("Game published. Link: " .. gameLink)

Mantle.SyncMarketing(tag)
print("Passes, products loaded")

if tag ~= "nil" and tag ~= nil then
	Tag:Set(tag)
end
