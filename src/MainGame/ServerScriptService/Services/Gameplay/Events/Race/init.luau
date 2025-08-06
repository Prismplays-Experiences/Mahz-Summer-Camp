local RaceInfo = require("@Info/Events/RaceInfo")
local types = require("./Race/RaceExecutorService/types")

type RaceService = types.RaceService

local Knit = require("@Packages/Knit")
local Signal = require("@Packages/Signal")

local Race = Knit.CreateService({
	Name = "Race",
	Client = {},
})

Race.MinPlayers = RaceInfo.eventProps.minPlayers
Race.LockWorkoutMachines = RaceInfo.eventProps.lockWorkoutMachines
Race.YieldClock = RaceInfo.eventProps.yieldClock
Race.Ended = Signal.new()
Race.Details = {
	Text = RaceInfo.eventProps.title,
	Image = RaceInfo.eventProps.image,
}

function Race.KnitStart(self: RaceService)
	self._raceExecutorService = Knit.GetService("RaceExecutorService")
end

function Race.Start(self: RaceService)
	self._raceExecutorService:Start()

	self.Ended:Fire()
end

function Race.Clean(self: RaceService)
	self._raceExecutorService:Clean()
end

return Race
