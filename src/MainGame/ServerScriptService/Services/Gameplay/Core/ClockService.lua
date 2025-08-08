--> Services
----------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local ServerStorage = game:GetService("ServerStorage")
-- local RunService = game:GetService("RunService")

--> Modules
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Signal = require(Packages:WaitForChild("Signal"))
local Knit = require(Packages:WaitForChild("Knit"))

local GeneralInfo = require(ReplicatedStorage:WaitForChild("Info"):WaitForChild("GeneralInfo"))

--> Variables
----------------------------------------

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
	self.CurrentTime = 0
	self.Days = 1
	self.MinutesPerDay = 2.5
	local START_HOUR = 8 -- 8 AM
	local END_HOUR = 22 -- 10 PM
	local HOUR_RANGE = END_HOUR - START_HOUR
	local KitchenTime = 12 -- 12PM
	self.KitchenRun = false
	local previousHour = 0

	self.ClockCycle = coroutine.create(function()
		while task.wait(1) do
			if self.ShouldYield then
				coroutine.yield()
			end
			local totalSecondsInDay = self.MinutesPerDay * 60
			local progress = math.clamp(self.CurrentTime / totalSecondsInDay, 0, 1)
			local currentHour = START_HOUR + (progress * HOUR_RANGE)
			local _wholeMinutes = math.floor((currentHour - math.floor(currentHour)) * 60)

			if previousHour < KitchenTime and currentHour >= KitchenTime and not self.KitchenRun and self.Days > 1 then
				self.KitchenRun = true
				self.KitchenService:SpawnFoods(5 * #Players:GetPlayers())
			end

			previousHour = currentHour

			self.CurrentTime += 1
			self.Client.Time:Set(self.CurrentTime)

			if self.CurrentTime >= (self.MinutesPerDay * 60) - 2 then
				self.CurrentTime = 0
				self.MinutesPerDay = math.clamp(self.MinutesPerDay + 0.5, 1, GeneralInfo.MinutesPerDay)
				self.Days += 1
				self.DayEnded:Fire()
				self.Client.DayEnded:FireAll()
				self.KitchenRun = false
				self.Client.Time:Set(self.CurrentTime + 1)
				self:YieldClock()
				previousHour = 0
			end
		end
	end)
end

function ClockService.Client:GetMinutesPerDay()
	return self.Server.MinutesPerDay
end

function ClockService:ResumeClock()
	self.ShouldYield = false
	if coroutine.status(self.ClockCycle) == "suspended" then
		coroutine.resume(self.ClockCycle)
	end
end

function ClockService:YieldClock()
	self.ShouldYield = true
end

function ClockService:GetSecondsLeft()
	local TimeToEnd = self.MinutesPerDay * 60 - self.CurrentTime
	return TimeToEnd
end

function ClockService:EndDay()
	local TimeToEnd = self.MinutesPerDay * 60 - self.CurrentTime
	if TimeToEnd < 5 then
		return
	end
	self:YieldClock()
	self.KitchenRun = true
	self.CurrentTime += TimeToEnd - 5
	task.wait(2)
	self:ResumeClock()
end

function ClockService:KnitStart()
	self.KitchenService = Knit.GetService("KitchenService")
end

return ClockService
