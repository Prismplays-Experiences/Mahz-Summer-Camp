--[=[ lunar
	about = "[DESCRIPTION] Used for switching between different places in the project"
]=]

local process = require("@lune/process")

local Config = require("@LuneModules/Config")

local args = process.args
local place = "MainGame"

local previousPlace = Config.GetCurrentPlace()

for _, arg in pairs(args) do
	for _, placeName in ipairs(Config.GetAllPlaces()) do
		if arg == placeName then
			place = placeName
			break
		end
	end
end

Config.SetPlace(place)

print("Switched from " .. previousPlace .. " to " .. place)
