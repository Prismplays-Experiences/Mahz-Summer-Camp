local Knit = require("@Packages/Knit")
local types = require("./RaceExecutorService/types")

type RaceExecutorService = types.RaceExecutorService

local RaceExecutorService = Knit.CreateService({
	Name = "RaceExecutorService",
	Client = {
		RaceStarted = Knit.CreateSignal("RaceStarted"),
		RaceEnded = Knit.CreateSignal("RaceEnded"),
	},
})

function RaceExecutorService.KnitStart(self: RaceExecutorService)
	self.bordersService = Knit.GetService("BordersService")
	self.powerupsService = Knit.GetService("PowerupsSpawnerService")
	self.boostsService = Knit.GetService("BoostsSpawnerService")
	self.spikesService = Knit.GetService("SpikesSpawnerService")
	self.raceProgressService = Knit.GetService("RaceProgressService")
	self.raceMembersService = Knit.GetService("RaceMembersService")
	self.raceUiService = Knit.GetService("RaceUiService")
	self.raceTimeService = Knit.GetService("RaceTimeService")
	self.raceRewardsService = Knit.GetService("RaceRewardsService")
end

function RaceExecutorService.Start(self: RaceExecutorService)
	self.raceUiService:Show()
	self.bordersService.ChangeCollision(true)
	self.powerupsService:Spawn()
	self.boostsService:Spawn()
	self.spikesService:Spawn()
	self.raceMembersService:AddAllPlayers()
	self.raceProgressService:Start()
	self.raceTimeService:Start()
	self.raceRewardsService:GiveRewards()
end

function RaceExecutorService.Clean(self: RaceExecutorService)
	self.raceUiService:Hide()
	self.bordersService.ChangeCollision(false)
	self.powerupsService:Clean()
	self.boostsService:Clean()
	self.spikesService:Clean()
	self.raceProgressService:Stop()
	self.raceMembersService:RemoveAllPlayers()
end

return RaceExecutorService
