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
	TotalWeightLost = 0,
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

function CreateTarget(Day, IdealWeight, MaxDays)
	MaxDays = MaxDays or GeneralInfo.MaxDays
	local k = 0.15 -- curve steepness
	local roundTo = 5

	local rawWeights = {}
	local totalRaw = 0

	-- Step 1: Generate exponential weights
	for i = 1, MaxDays do
		local w = math.exp(k * i)
		table.insert(rawWeights, w)
		totalRaw += w
	end

	-- Step 2: Scale and round weights
	local scale = IdealWeight / totalRaw
	local scaledWeights = {}
	local roundedWeights = {}
	local totalRounded = 0

	for i = 1, MaxDays do
		local scaled = rawWeights[i] * scale
		scaledWeights[i] = scaled
		local rounded = math.floor((scaled / roundTo) + 0.5) * roundTo
		roundedWeights[i] = rounded
		totalRounded += rounded
	end

	-- Step 3: Fix rounding error by adjusting largest weights
	local difference = IdealWeight - totalRounded
	local adjustmentStep = roundTo * (difference > 0 and 1 or -1)
	local remaining = math.abs(difference)

	while remaining > 0 do
		for i = MaxDays, 1, -1 do
			local newValue = roundedWeights[i] + adjustmentStep
			if newValue >= 0 then
				roundedWeights[i] = newValue
				remaining -= roundTo
				if remaining <= 0 then
					break
				end
			end
		end
	end

	-- Step 4: Return the value for the requested day
	return roundedWeights[Day]
end

-- for day = 1, 24 do
-- 	local loss = CreateTarget(day, GeneralInfo.Weight, 24)
-- 	print(string.format("Day %02d: Lose %.2f lbs", day, loss))
-- end

--> Main Functions
----------------------------------------
function TargetService:KnitInit() end

function TargetService:SetTarget()
	local Day = GetDays()
	local IdealWeight = GeneralInfo.Weight - GeneralInfo.EndWeight
	self.TargetWeight = CreateTarget(Day, IdealWeight, GeneralInfo.MaxDays)
	self.TotalWeightLost += self.TargetWeight
	self.Client.DisplayTarget:FireAll(self.TargetWeight, GeneralInfo.Weight - self.TotalWeightLost, Day)
end

function TargetService:GetTarget()
	return GeneralInfo.Weight - self.TotalWeightLost
end

return TargetService
