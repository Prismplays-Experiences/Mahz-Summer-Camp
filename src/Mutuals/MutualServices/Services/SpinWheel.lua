--> Services
----------------------------------------
local CollectionService = game:GetService("CollectionService")

--> Knit Setup
----------------------------------------
local Knit = require("@Packages/Knit")
local WheelService = Knit.CreateService({
	Name = "WheelService",
	Client = {},
})

--> Modules
----------------------------------------
local WheelSpinnerContents = require("@Modules/Client/Rewards/WheelSpinnerContents")

function WheelService:ValidateWheelSpinner(Player, Type, index)
	local PrivateStats = Player:WaitForChild("PrivateStats")
	if Type == "check" then
		if PrivateStats:WaitForChild("Spins").Value >= 1 then
			CollectionService:AddTag(Player, "ValidatedSpins")
			return true
		else
			return false, "purchase"
		end
	elseif Type == "reward" then
		if CollectionService:HasTag(Player, "ValidatedSpins") then
			CollectionService:RemoveTag(Player, "ValidatedSpins")
			WheelSpinnerContents.Data[index].Reward(Player)
			PrivateStats:WaitForChild("Spins", 99).Value -= 1
			Player:SetAttribute("SpinClaimed", true)
		end
	end

	return nil
end

function WheelService.Client:ValidateWheelSpinner(Player, Type, index)
	return self.Server:ValidateWheelSpinner(Player, Type, index)
end

return WheelService
