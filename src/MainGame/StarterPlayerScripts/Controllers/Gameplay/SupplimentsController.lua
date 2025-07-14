--> Services
-----------------------------------------
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local MarketplaceService = game:GetService('MarketplaceService')
local ServerStorage = game:GetService('ServerStorage')

--> Modules
-----------------------------------------
local Packages = ReplicatedStorage:WaitForChild('Packages')
local Knit = require(Packages:WaitForChild('Knit'))


--> Assets
-----------------------------------------
local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local Main = PlayerGui:WaitForChild('Main')
local CoreFrames = Main:WaitForChild('Core')
local EventsDisplay  =CoreFrames:WaitForChild('EventsDisplay')

--> Knit Setup
-----------------------------------------
local SupplimentsController= Knit.CreateController {
    Name = 'SupplimentsController',
}

function TimeToString(Time)
    local minutes = math.floor(Time / 60)
    local seconds = Time % 60
    return string.format("%02d:%02d", minutes, seconds)
end

function SupplimentsController:KnitStart()
    self.SuplimentsService = Knit.GetService('SupplimentsService')
    self.SuplimentsService.UseSuppliment:Connect(function(ItemName, Time)
        EventsDisplay[ItemName].Visible = true
        for i = 1, Time do
            EventsDisplay[ItemName].Time.Text = TimeToString(Time - i)
            task.wait(1)
        end
        EventsDisplay[ItemName].Visible = false
    end)
end

return SupplimentsController