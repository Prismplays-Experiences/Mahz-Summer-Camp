--> Services
----------------------------------------

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--> Knit Setup
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild('Packages')
local Knit = require(Packages:WaitForChild("Knit"))
local WheelService = Knit.CreateService {
    Name = "WheelService",
    Client = {}
}

--> Modules
----------------------------------------
local Modules = ReplicatedStorage:WaitForChild('Modules')
local WheelSpinnerContents = require(Modules:WaitForChild('Client'):WaitForChild('Rewards'):WaitForChild("WheelSpinnerContents"))

function WheelService:KnitInit()

end

function WheelService:KnitStart()

end

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
end

function WheelService.Client:ValidateWheelSpinner(Player, Type, index)
    return self.Server:ValidateWheelSpinner(Player, Type, index)
end

return WheelService