--[=[ lunar
	about = "[DESCRIPTION] Creates game file and inserts all instances into it"
]=]

local InstancesManager = require("@LuneModules/InstancesManager")
local GameManager = require("@LuneModules/GameManager")

GameManager.Build()
print("Game file created successfully")

print("Loading instances...")
local timePassed = InstancesManager.Load()
print("Loaded instances in " .. tostring(timePassed) .. " seconds")