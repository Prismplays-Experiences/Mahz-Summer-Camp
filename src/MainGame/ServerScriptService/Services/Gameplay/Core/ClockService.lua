--> Services
----------------------------------------
local Players = game:GetService("Players")

--> Modules
----------------------------------------
local Signal = require("@Packages/Signal")
local Knit = require("@Packages/Knit")

local GeneralInfo = require("@Info/GeneralInfo")
--> Knit Setup
----------------------------------------
local ClockService = Knit.CreateService({
	Name = "ClockService",
	DayEnded = Signal.new(),
	Days = 1,
	Client = {
		DayEnded = Knit.CreateSignal(),
		Time = Knit.CreateProperty(0),
	},
})

--> Utility Functions
----------------------------------------
-- function GetCurrentHourFromSeconds(seconds, startHour, endHour)
--     startHour = startHour or 8     -- default to 8 AM
--     endHour = endHour or 22        -- default to 8 PM

--     local totalSeconds = 60 * 60 * (endHour - startHour) -- total time range
--     local progress = math.clamp(seconds / totalSeconds, 0, 1)
--     local currentHour = startHour + (progress * (endHour - startHour))

--     return currentHour
-- end

--> Main Functions
----------------------------------------
function ClockService:KnitInit()
    local CurrentTime = 0
    self.Days = 1
    self.MinutesPerDay = 2.5 -- 1.5
    local START_HOUR = 8     -- 8 AM
	local END_HOUR = 22      -- 10 PM
	local HOUR_RANGE = END_HOUR - START_HOUR
	local KitchenTime = 12 -- PM
	local KitchenRun = false
	local previousHour = 0

	self.ClockCycle = coroutine.create(function()
		while task.wait(1) do
			local totalSecondsInDay = self.MinutesPerDay * 60
			local progress = math.clamp(CurrentTime / totalSecondsInDay, 0, 1)
			local currentHour = START_HOUR + (progress * HOUR_RANGE)

			-- Run once when crossing 12 PM
			if previousHour < KitchenTime and currentHour >= KitchenTime and not KitchenRun and self.Days > 1 then
				KitchenRun = true
				self.KitchenService:SpawnFoods(5 * #Players:GetPlayers())
			end

			previousHour = currentHour -- update for next tick

			CurrentTime += 1
			self.Client.Time:Set(CurrentTime)

			if CurrentTime >= (self.MinutesPerDay * 60) - 2 then
				CurrentTime = 0
				self.MinutesPerDay = math.clamp(self.MinutesPerDay + 0.5, 1, GeneralInfo.MinutesPerDay)
				self.DayEnded:Fire()
				self.Days += 1
				self.Client.DayEnded:FireAll()
				KitchenRun = false
				self.Client.Time:Set(CurrentTime + 1)
				self:YieldClock()
				previousHour = 0 -- reset hour tracking
			end
		end
	end)
end

function ClockService.Client:GetMinutesPerDay()
	return self.Server.MinutesPerDay
end

function ClockService:ResumeClock()
	if coroutine.status(self.ClockCycle) == "suspended" then
		coroutine.resume(self.ClockCycle)
	end
end

function ClockService:YieldClock()
	if coroutine.status(self.ClockCycle) == "running" then
		coroutine.yield()
	end
end

function ClockService:KnitStart()
	self.KitchenService = Knit.GetService("KitchenService")
end

return ClockService
