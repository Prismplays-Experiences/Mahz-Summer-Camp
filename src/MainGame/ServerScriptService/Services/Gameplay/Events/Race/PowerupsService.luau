local Knit = require("@Packages/Knit")
local RaceInfo = require("@Info/Events/Race")
local types = require("./types")

local POWERUPS_COUNT = RaceInfo.powerups.count

type PowerupsService = types.PowerupsService

local PowerupsService = Knit.CreateService({
	Name = "PowerupsService",
	Client = {
		PowerupSpawned = Knit.CreateSignal("PowerupSpawned"),
	},
})

function PowerupsService.KnitInit(self: PowerupsService)
	self.landmarksService = Knit.GetService("LandmarksService")
end

function PowerupsService.SpawnAll(self: PowerupsService)
	for _ = 1, POWERUPS_COUNT do
		self._spawnOne()
	end
end

function PowerupsService._spawnOne()

end

return PowerupsService
