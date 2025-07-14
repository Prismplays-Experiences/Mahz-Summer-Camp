--> Services
-----------------------------------------
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local MarketplaceService = game:GetService('MarketplaceService')
local ServerStorage = game:GetService('ServerStorage')

--> Modules
-----------------------------------------
local Packages = ReplicatedStorage:WaitForChild('Packages')
local Knit = require(Packages:WaitForChild('Knit'))

local IAPDATA = require(ReplicatedStorage:WaitForChild('Info'):WaitForChild('IAPDATA'))

--> Knit Setup
-----------------------------------------
local SupplimentsService = Knit.CreateService {
    Name = 'SupplimentsService',
    Client = {
        UseSuppliment = Knit.CreateSignal(),
    }
}

function SupplimentsService:UseSuppliment(Player, Tool, Time)
    if not Tool then return end
    local ItemName = Tool.Name
    Player:AddTag(ItemName)
    self.Client.UseSuppliment:Fire(Player, ItemName, Time)
    task.delay(Time, function()
        Player:RemoveTag(ItemName)
    end)
end

function SupplimentsService:RecoverHealth(Player, Amount)
    self.GeneralService.Client.InjuredCount:SetFor(Player, self.GeneralService.Client.InjuredCount:GetFor(Player) - Amount)
end

function SupplimentsService:KnitStart()
    self.GeneralService = Knit.GetService('GeneralGameplay')
end

return SupplimentsService