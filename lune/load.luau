--[=[ lunar
	about = "[DESCRIPTION] Creates game file and inserts all instances into it"
]=]
local process = require("@lune/process")

local InstancesManager = require("@LuneModules/InstancesManager")
local GameManager = require("@LuneModules/GameManager")
local Config = require("@LuneModules/Config")

local function buildAndLoadPlace(place: string?)
	GameManager.Build(place)
	print("Game file created successfully")

	print("Loading instances...")
	local timePassed = InstancesManager.Load(place)
	print("Loaded instances in " .. tostring(timePassed) .. " seconds")
end

local args = process.args
local loadAllPlaces = false

for _, arg in args do
	if arg == "--all" or arg == "-a" then
		loadAllPlaces = true
	end
end

if not loadAllPlaces then
	buildAndLoadPlace()
	return
end

for _, place in ipairs(Config.GetAllPlaces()) do
	buildAndLoadPlace(place)
end
