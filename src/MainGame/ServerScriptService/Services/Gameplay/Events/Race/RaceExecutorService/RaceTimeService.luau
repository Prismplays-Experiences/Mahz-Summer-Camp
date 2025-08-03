

local RaceInfo = require("@Info/Events/RaceInfo")
local Knit = require("@Packages/Knit")
local types = require("./types")

type RaceTimeService = types.RaceTimeService

local RaceTimeService = Knit.CreateService {
	Name = "RaceTimeService",
	Client = {
		Time = Knit.CreateProperty(0),
	},
}

function RaceTimeService.Start(self: RaceTimeService)
	self:_setTime(RaceInfo.eventProps.duration)

	for time = RaceInfo.eventProps.duration, 1, -1 do
		task.wait(0.5)
		self:_decreaseTime()
		task.wait(0.5)
	end
end

function RaceTimeService.GetTime(self: RaceTimeService)
	return self._time
end

function RaceTimeService._decreaseTime(self: RaceTimeService)
	local currentTime = self:GetTime()
	local newTime = math.max(currentTime - 1, 0)

	self:_setTime(newTime)
end

function RaceTimeService._setTime(self: RaceTimeService, time: number)
	self._time = time
	self.Client.Time:Set(time)
end

return RaceTimeService
