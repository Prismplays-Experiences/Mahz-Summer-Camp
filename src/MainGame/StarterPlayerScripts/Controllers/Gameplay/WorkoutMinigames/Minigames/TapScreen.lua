--> Services
----------------------------------------
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local Lighting = game:GetService('Lighting')
local TweenService = game:GetService('TweenService')
local UserInputService = game:GetService('UserInputService')

--> Modules
----------------------------------------
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Utils = Modules:WaitForChild('Utils')
local SpringMotion = require(Utils:WaitForChild('Spr'))

local Packages = ReplicatedStorage:WaitForChild('Packages')
local Signal = require(Packages:WaitForChild('Signal'))
local Knit = require(Packages:WaitForChild('Knit'))

local ProgressBarController = require(script.Parent.Parent:WaitForChild('Progressbar'))

--> Assets
----------------------------------------
local Assets = ReplicatedStorage:WaitForChild('Assets')
local Minigames = Assets:WaitForChild('Minigames')

local Models = ReplicatedStorage:WaitForChild('Models')
local SoundEffects = Models:WaitForChild('SoundEffects')

local PlayerGui = Players.LocalPlayer:WaitForChild('PlayerGui')
local Main = PlayerGui:WaitForChild('Main')
local GameplayFrames = Main:WaitForChild('Gameplay')
local TapGameplay = GameplayFrames:WaitForChild('TapGameplay')
local ProgressBar = TapGameplay:WaitForChild('ProgressBar')
local ExitMachine = TapGameplay:WaitForChild('ExitMachine')

local Confetti = Assets:WaitForChild('Confetti')

--> Variables
----------------------------------------


--> Knit Setup
----------------------------------------
local TapGameplayMinigame = Knit.CreateController {
    Name = 'TapScreenMinigame',
    Speed = 1.2,
    TapCount = 0,
    StopEvent = Signal.new()
}


--> Utility Functions
----------------------------------------


--> Main Functions
----------------------------------------

function ShortNotification(Text,TextColor,Sound)
    local NotificationTemplete = Confetti:WaitForChild('ShortNotification'):Clone()
    local UIStroke = NotificationTemplete:WaitForChild('UIStroke')
    NotificationTemplete.Text = Text
    NotificationTemplete.TextColor3 = TextColor or Color3.fromRGB(255, 255, 255)
    NotificationTemplete.Visible = false
    NotificationTemplete.Parent = TapGameplay
    local tweeninstroke = TweenService:Create(UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Transparency = 0})
    local tweenintext = TweenService:Create(NotificationTemplete, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0})
    local tweentextpos = TweenService:Create(NotificationTemplete, TweenInfo.new(1.6, Enum.EasingStyle.Quad), {Position = UDim2.fromScale(0.5,NotificationTemplete.Position.Y.Scale-0.35)})
    local tweenoutstroke = TweenService:Create(UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Transparency = 1})
    local tweenouttext = TweenService:Create(NotificationTemplete, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 1})
    tweeninstroke:Play()
    tweentextpos:Play()
    tweenintext:Play()
    NotificationTemplete.Visible = true
    if Sound then Sound:Play() end
    task.wait(0.5)
    tweenoutstroke:Play()
    tweenouttext:Play()
    tweenouttext.Completed:Connect(function()
        NotificationTemplete:Destroy()
    end)
end 

function GetRandomSignedValue(value)
    return math.random() * 2 * value - value
end


--> Main Functions
----------------------------------------


function TapGameplayMinigame:Start(Level)
    if self.Enabled then return end
    self.BarControl:Start(self.StopEvent)
    TapGameplay.Visible = true
    self.Enabled = true
    local rate = self.ThrowRate or 1
    TapGameplay:WaitForChild('ActionText').Visible = true
    self.BarControl:AdjustSpeed(self.Speed)
    coroutine.wrap(function()
        while self.Enabled do
            task.wait(math.random(1, math.random(2,12)))
            local NewSigned = GetRandomSignedValue(100)/10
            self.Speed += NewSigned
            if NewSigned >0 then
                ShortNotification('Faster!!',Color3.fromRGB(255, 125, 3))
            else
                ShortNotification('Slower 😁',Color3.fromRGB(3, 255, 33))
            end
            self.BarControl:AdjustSpeed(math.clamp(self.Speed, 1.2, 5))
        end
    end)()
    local Data = {
        Stopped = self.BarControl.Stopped,
        Failed = self.BarControl.Failed,
        Value = self.BarControl.ProgressValue,
        Stop = self.StopEvent,
    }
    return Data
end

function TapGameplayMinigame:Stop()
    self.BarControl:Stop()
    self.Enabled = false
    TapGameplay.Visible = false
    self.Speed = 1.2
    self.TapCount = 0
end

function TapGameplayMinigame:KnitInit()
    self.BarControl = ProgressBarController:new(ProgressBar)
    ExitMachine.MouseButton1Click:Connect(function()
        self:Stop()
    end)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end -- Ignore inputs used by UI
        if not self.Enabled then return end -- Only process inputs if the game is active
        local inputType = input.UserInputType

        if inputType == Enum.UserInputType.Touch
            or inputType == Enum.UserInputType.MouseButton1
            or inputType == Enum.UserInputType.MouseButton2
            or inputType == Enum.UserInputType.Gamepad1
            or inputType == Enum.UserInputType.Gamepad2
            or inputType == Enum.UserInputType.Gamepad3
            or inputType == Enum.UserInputType.Gamepad4
            or inputType == Enum.UserInputType.Gamepad5
            or inputType == Enum.UserInputType.Gamepad6
            or inputType == Enum.UserInputType.Gamepad7
            or inputType == Enum.UserInputType.Gamepad8 then
            self.BarControl:Increment(0.15 )
            self.TapCount +=1
            if self.TapCount >=3 then
                TapGameplay:WaitForChild('ActionText').Visible = false
            end
        end
    end)
    self.StopEvent:Connect(function()
        self:Stop()
    end)
end

return TapGameplayMinigame