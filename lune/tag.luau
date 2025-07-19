--[=[ lunar
	about = "sets tag. This is used to identify the version of the game, such as dev, prod, or feature_xxx"
]=]

local process = require("@lune/process")

local Tag = require("@LuneModules/Tag")

local args = process.args
local tag = nil
local get = false

for _, arg in args do
	if arg == "dev" or arg == "prod" or string.match(arg, "feature_") then
		tag = arg
	elseif arg == "--get" or arg == "-g" then
		get = true
	end
end

if get then
	local currentTag = Tag.Get()
	print("Current tag: " .. tostring(currentTag))
else
	local previousTag = Tag:Set(tag)
	print(`Tag updated successfully from "{previousTag}" to "{tag}"`)
end
