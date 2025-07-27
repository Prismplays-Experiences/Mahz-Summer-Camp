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
local WeightControl = Knit.CreateService({
	Name = "WeightControl",
	Client = {},
})

--> Utility Functions
-----------------------------------------

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
function WeightControl:DecreaseWeight(Player, Value, FoodLoss)
	local Weight = Player:WaitForChild("leaderstats"):WaitForChild("Weight")
	local CanAdd = true
	local WeightLossMultiplier = Player:GetAttribute("WeightLossMultiplier") or 1

	if Value > 0 then
		if Player:HasTag("FiberSupplement") and FoodLoss then
			Value *= IAPDATA.Suppliments.FiberSupplement.Multipler
		end
		if Player:HasTag("HyperShredMax") then
			Value *= IAPDATA.Suppliments.HyperShredMax.Multiplier
		end
		if Player:HasTag("FatBurner") then
			Value *= IAPDATA.Suppliments.FatBurner.Multiplier
		end
		Value *= WeightLossMultiplier
	end
	if Player:HasTag("WeightGainShield") and Value < 0 then
		CanAdd = false
	end

	if CanAdd then
		local WeightVal = math.clamp(Weight.Value - Value, GeneralInfo.EndWeight, GeneralInfo.Weight)
		Weight.Value = WeightVal
		if Weight.Value < 0 then
			Weight.Value = 0
		end
	else
		SendNotification(
			Player,
			"Protected by weight loss shield!",
			Color3.fromRGB(106, 255, 0),
			3,
			false,
			SoundEffects.Positive
		)
	end

	return CanAdd, Value
end

function WeightControl.Client:DecreaseWeight(Player, Value, FoodLoss)
	local status, Weight = self.Server:DecreaseWeight(Player, Value, FoodLoss)
	return status, Weight
end

---------------------------------
return WeightControl
