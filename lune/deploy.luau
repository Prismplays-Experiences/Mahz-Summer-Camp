---@diagnostic disable: undefined-type

--[=[ lunar
	about = "[DESCRIPTION] Publishes game"
]=]

local process = require("@lune/process")
local Mantle = require("@LuneModules/Mantle")
local Tag = require("@LuneModules/Tag")
local GameManager = require("@LuneModules/GameManager")

local args = process.args
local tag = Tag.Get()
for _, arg in args do
	if arg == "dev" or arg == "prod" or string.match(arg, "feature_") then
		tag = arg
		break
	end
end

if not GameManager.AreAllPlacesBuilt() then
	print("Not all places are built. Please build all places before publishing")
	return
end

if tag == "nil" and Tag.Get() == "nil" then
	print("No tag provided. Please specify a tag such as 'dev', 'prod', or 'feature_xxx'.")
	return
end

Mantle.Deploy(tag)
local gameLink = Mantle.GetGameLink(tag)
print("Game published. Link: " .. gameLink)

if tag ~= nil then
	Tag:Set(tag)
end
