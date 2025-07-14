--> Services
----------------------------------------
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--> Modules
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild('Packages')
local Knit = require(Packages:WaitForChild('Knit'))

--> Assets
----------------------------------------
local Player =  game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild('PlayerGui')
local MainGui = PlayerGui:WaitForChild('Main')
local GameplayUI = MainGui:WaitForChild('GameplayUI')
local StatusUI = GameplayUI:WaitForChild('Status')
local SubStatusUI = GameplayUI:WaitForChild('SubStatus')
local BlowButton = GameplayUI:WaitForChild('Blow')
local AFKButton = GameplayUI:WaitForChild('AFK')

local PlayerModule = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()

--> Utility Functions
----------------------------------------

--> Main Functions
----------------------------------------
local RoundController   = Knit.CreateController {
    Name = "RoundController",
}

function BlowBalloon()
    BlowButton.Visible = true
end



function RoundController:KnitStart()
    local RoundService = Knit.GetService('RoundService')
    local RoundLoop = Knit.GetService('RoundLoop')
    RoundService.StatusValue:Observe(function(Value)
        StatusUI.Text = Value
    end)
    RoundService.SubStatusValue:Observe(function(Value)
        SubStatusUI.Text = Value
    end)
    RoundLoop.BlowBalloon:Connect(function()
        BlowBalloon()
    end)

    RoundLoop.StopBlowing:Connect(function()
        BlowButton.Visible = false
    end)


    BlowButton.MouseButton1Down:Connect(function()
        RoundLoop:IncrementBalloon()
    end)
    BlowButton.MouseButton1Up:Connect(function()
        RoundLoop:StopIncrementBalloon()
    end)
    RoundService:GameLoaded()

    RoundLoop.EnableControls:Connect(function()
        PlayerModule:Enable()
    end)
    RoundLoop.DisableControls:Connect(function()
        PlayerModule:Disable()
    end)

    AFKButton.MouseButton1Click:Connect(function()
        RoundLoop:ToggleAFK():andThen(function(isAFK)
            if isAFK then
                AFKButton.TextLabel.Text = "AFK ON"
                AFKButton.TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            else
                AFKButton.TextLabel.Text = "AFK"
                AFKButton.TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
            end
        end):catch(function(err)
            warn("Error toggling AFK:", err)
        end)
    end)

end

return RoundController