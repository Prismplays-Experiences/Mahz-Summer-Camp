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
	self.powerupsService = Knit.GetService("PowerupsSpawnerService")
	self.boostsService = Knit.GetService("BoostsSpawnerService")
	self.spikesService = Knit.GetService("SpikesSpawnerService")
	self.raceProgressService = Knit.GetService("RaceProgressService")
	self.raceMembersService = Knit.GetService("RaceMembersService")
	self.raceUiService = Knit.GetService("RaceUiService")
end

function Race.Start(self: RaceService)
	self.raceUiService:Show()
	self.bordersService.ChangeCollision(true)
	self.powerupsService:Spawn()
	self.boostsService:Spawn()
	self.spikesService:Spawn()
	self.raceMembersService:AddAllPlayers()
	self.raceProgressService:Start()
end

function Race.Stop(self: RaceService)
	self.raceUiService:Hide()
	self.bordersService.ChangeCollision(false)
	self.powerupsService:Clean()
	self.boostsService:Clean()
	self.spikesService:Clean()
	self.raceProgressService:Stop()
	self.raceMembersService:RemoveAllPlayers()
end

return Race
