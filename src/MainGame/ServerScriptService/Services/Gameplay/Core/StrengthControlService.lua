--> Services
-----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--> Modules
-----------------------------------------
local Knit = require("@Packages/Knit")
local IAPDATA = require("@Info/IAPDATA")
local GeneralInfo = require("@Info/GeneralInfo")

--> Assets
-----------------------------------------
local SoundEffects = ReplicatedStorage:WaitForChild("Models"):WaitForChild("SoundEffects")

--> Knit Setup
-----------------------------------------
local StrengthControl = Knit.CreateService({
	Name = "StrengthControl",
	Client = {},
})

--> Utility Functions
-----------------------------------------

function RoundIfAbove1DP(num)
	if tostring(num):match("%.%d%d+") then
		return tonumber(string.format("%.2f", num))
	end
	return num
end

function SendNotification(player, msg, color, duration, reward, sound)
	local Notify = Knit.GetService("NotificationService")
	Notify:SendNotification(player, {
		message = msg,
		color = color or Color3.fromRGB(255, 255, 255),
		duration = duration or 2,
		reward = reward or false,
		sound = sound or SoundEffects.Positive,
	})
end

--> Main Functions
-----------------------------------------
function StrengthControl:DecreaseStrength(Player, Value, FoodGain)
	local Strength = Player:WaitForChild("leaderstats"):WaitForChild("Strength")
	local CanAdd = true
	local StrengthGainMultiplier = Player:GetAttribute("StrengthGainMultiplier") or 1
	local DailyEnergyBoost = Player:GetAttribute("DailyEnergyBoost") or 1
	local StarterPackBoost = Player:GetAttribute("StarterPackBoost") or 1

	if Value > 0 then
		if Player:HasTag("FiberSupplement") and FoodGain then
			Value *= IAPDATA.Suppliments.FiberSupplement.Multipler
		end
		if Player:HasTag("HyperShredMax") then
			Value *= IAPDATA.Suppliments.HyperShredMax.Multiplier
		end
		if Player:HasTag("FatBurner") then
			Value *= IAPDATA.Suppliments.FatBurner.Multiplier
		end
		Value *= StrengthGainMultiplier
		Value *= DailyEnergyBoost
		Value *= StarterPackBoost
	end
	if Player:HasTag("StrengthGainShield") and Value < 0 then
		CanAdd = false
	end

	if CanAdd then
		local StrengthVal = math.clamp(Strength.Value - Value, GeneralInfo.EndStrength, GeneralInfo.Strength)
		Strength.Value = StrengthVal
		if Strength.Value < 0 then
			Strength.Value = 0
		end
	else
		SendNotification(
			Player,
			"Protected by Strength Gain shield!",
			Color3.fromRGB(106, 255, 0),
			3,
			false,
			SoundEffects.Positive
		)
	end
	local val = RoundIfAbove1DP(Value)
	if val then
		Value = val
	end
	return CanAdd, Value
end

function StrengthControl.Client:DecreaseStrength(Player, Value, FoodGain)
	local status, Strength = self.Server:DecreaseStrength(Player, Value, FoodGain)
	return status, Strength
end

---------------------------------
return StrengthControl
