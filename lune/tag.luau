--[=[ lunar
	about = "sets tag. This is used to identify the version of the game, such as dev, prod, or feature_xxx"
]=]

local process = require("@lune/process")

local Tag = require("@LuneModules/Tag")

local args = process.args
local tag = nil

for _, arg in args do
	if arg == "dev" or arg == "prod" or string.match(arg, "feature_") then
		tag = arg
		break
	end
end

Tag:Set(tag)
print("Tag updated successfully to: " .. tostring(tag))
