--!nonstrict
local InstancesSaver = require("@LuneModules/InstancesManager/InstancesSaver")
local InstancesLoader = require("@LuneModules/InstancesManager/InstancesLoader")

export type InstancesManager = {
	Load: () -> number,
	Save: () -> number,
}

local InstancesManager = {}

function InstancesManager.Load(place: string?)
	local startTime = os.time()

	InstancesLoader:LoadEverything(place)

	local endTime = os.time()
	local timePassed = endTime - startTime

	return timePassed
end

function InstancesManager.Save()
	local startTime = os.time()

	InstancesSaver:SaveEverything()

	local endTime = os.time()
	local timePassed = endTime - startTime

	return timePassed
end

return InstancesManager
