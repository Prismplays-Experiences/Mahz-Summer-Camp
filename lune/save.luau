--[=[ lunar
	about = "[DESCRIPTION] Saves all instances of the project"
]=]

local InstancesManager = require("@LuneModules/InstancesManager")
local Terminal = require("@LuneModules/Terminal")

local BULK_LOG = true

Terminal.Log("save_log", function()
	print("Saving instances...")
	local timePassed = InstancesManager.Save()
	print("Saved instances in " .. tostring(timePassed) .. " seconds")
end, BULK_LOG)
