local Knit = require("@Packages/Knit")
local types = require("./Race/types")

type RaceService = types.RaceService

local Race = Knit.CreateService({
	Name = "Race",
	Client = {
		RaceStarted = Knit.CreateSignal("RaceStarted"),
		RaceEnded = Knit.CreateSignal("RaceEnded"),
	},
})

function Race.KnitStart(self: RaceService)
	self.bordersService = Knit.GetService("BordersService")
	self.powerupsService = Knit.GetService("PowerupsService")
	self.boostsService = Knit.GetService("BoostsService")
end

function Race.Start(self: RaceService)
	self.bordersService.ChangeCollision(true)
	self.powerupsService:SpawnAll()
	self.boostsService:SpawnAll()
end

return Race