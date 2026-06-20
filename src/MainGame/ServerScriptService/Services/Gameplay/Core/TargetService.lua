--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")
local GeneralInfo = require("@Info/GeneralInfo")

--> Variables
----------------------------------------

--> Knit Setup
----------------------------------------
local TargetService = Knit.CreateService({
	Name = "TargetService",
	TotalStrengthLost = 0,
	Client = {
		DisplayTarget = Knit.CreateSignal(),
	},
})

--> Utility Functions
----------------------------------------
function GetDays()
	local ClockService = Knit.GetService("ClockService")
	return ClockService.Days
end

function CreateTarget(Day, IdealStrength, MaxDays)
	MaxDays = MaxDays or GeneralInfo.MaxDays
	local k = 0.15 -- curve steepness
	local roundTo = 5

	local rawStrengths = {}
	local totalRaw = 0

	-- Step 1: Generate exponential Strengths
	for i = 1, MaxDays do
		local w = math.exp(k * i)
		table.insert(rawStrengths, w)
		totalRaw += w
	end

	-- Step 2: Scale and round Strengths
	local scale = IdealStrength / totalRaw
	local scaledStrengths = {}
	local roundedStrengths = {}
	local totalRounded = 0

	for i = 1, MaxDays do
		local scaled = rawStrengths[i] * scale
		scaledStrengths[i] = scaled
		local rounded = math.floor((scaled / roundTo) + 0.5) * roundTo
		roundedStrengths[i] = rounded
		totalRounded += rounded
	end

	-- Step 3: Fix rounding error by adjusting largest Strengths
	local difference = IdealStrength - totalRounded
	local adjustmentStep = roundTo * (difference > 0 and 1 or -1)
	local remaining = math.abs(difference)

	while remaining > 0 do
		for i = MaxDays, 1, -1 do
			local newValue = roundedStrengths[i] + adjustmentStep
			if newValue >= 0 then
				roundedStrengths[i] = newValue
				remaining -= roundTo
				if remaining <= 0 then
					break
				end
			end
		end
	end

	-- Step 4: Return the value for the requested day
	return roundedStrengths[Day]
end

-- for day = 1, 24 do
-- 	local Gain = CreateTarget(day, GeneralInfo.Strength, 24)
-- 	print(string.format("Day %02d: Lose %.2f lbs", day, Gain))
-- end

--> Main Functions
----------------------------------------
function TargetService:KnitInit() end

function TargetService:SetTarget()
	local Day = GetDays()
	local IdealStrength = GeneralInfo.Strength - GeneralInfo.EndStrength
	self.TargetStrength = CreateTarget(Day, IdealStrength, GeneralInfo.MaxDays)
	self.TotalStrengthLost += self.TargetStrength
	self.Client.DisplayTarget:FireAll(self.TargetStrength, GeneralInfo.Strength - self.TotalStrengthLost, Day)
end

function TargetService:GetTarget()
	return GeneralInfo.Strength - self.TotalStrengthLost
end

return TargetService
