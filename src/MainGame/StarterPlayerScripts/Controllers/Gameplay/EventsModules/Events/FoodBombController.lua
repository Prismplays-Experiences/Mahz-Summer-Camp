--> Services
----------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService('ServerStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--> Modules
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Signal = require(Packages:WaitForChild("Signal"))
local Knit = require(Packages:WaitForChild("Knit"))

local Info = ReplicatedStorage:WaitForChild("Info")

--. Assets
----------------------------------------
local Player = game.Players.LocalPlayer
local Assets = ReplicatedStorage:WaitForChild('Assets')
local Confetti = Assets:WaitForChild('Confetti')

local PlayerGui = Player.PlayerGui
local Main = PlayerGui:WaitForChild('Main')
local EventsInterfaces = Main:WaitForChild('EventsInterfaces')
local CoreFrames = Main:WaitForChild('Core')
local HUD = Main:WaitForChild('HUD')
local FoodBombFrame = EventsInterfaces:WaitForChild('FoodBomb')
local StatusTxt = FoodBombFrame:WaitForChild('Status')
local SubStatusTxt = FoodBombFrame:WaitForChild('SubStatus')

local Models = ReplicatedStorage:WaitForChild('Models')
local SoundEffects = Models:WaitForChild('SoundEffects')

--> Variables
----------------------------------------
local EventsModules = {}

--> Knit Setup 
----------------------------------------
local EventsController = Knit.CreateController {
    Name = "FoodBombController",
}

--> Utility Functions
----------------------------------------
function ShortNotification(Text,TextColor, Random)
    local NotificationTemplete = Confetti:WaitForChild('ShortNotification'):Clone()
    local randomx = math.random(25,85)/100
    local randomy = math.random(35,85)/100
    if Random then
        NotificationTemplete.Position = UDim2.fromScale(randomx, randomy)
    else
        NotificationTemplete.Position = UDim2.fromScale(0.5, 0.5)
    end

    local UIStroke = NotificationTemplete:WaitForChild('UIStroke')
    NotificationTemplete.Text = Text
    NotificationTemplete.TextColor3 = TextColor or Color3.fromRGB(255, 255, 255)
    NotificationTemplete.Visible = false
    NotificationTemplete.Parent = Player.PlayerGui:WaitForChild('Main'):WaitForChild('EventsInterfaces')
    local tweeninstroke = TweenService:Create(UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Transparency = 0})
    local tweenintext = TweenService:Create(NotificationTemplete, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0})
    local tweentextpos = TweenService:Create(NotificationTemplete, TweenInfo.new(1.6, Enum.EasingStyle.Quad), {Position = UDim2.fromScale(NotificationTemplete.Position.X.Scale,NotificationTemplete.Position.Y.Scale-0.35)})
    local tweenoutstroke = TweenService:Create(UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Transparency = 1})
    local tweenouttext = TweenService:Create(NotificationTemplete, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 1})
    tweeninstroke:Play()
    tweentextpos:Play()
    tweenintext:Play()
    NotificationTemplete.Visible = true
    task.wait(0.5)
    tweenoutstroke:Play()
    tweenouttext:Play()
    tweenouttext.Completed:Connect(function()
        NotificationTemplete:Destroy()
    end)
end 

function RoundTo2DecimalPlaces(value)
    return math.floor(value * 100 + 0.5) / 100
end

function EnableFrame(Frames,TargetFrame)
    for _,frame in Frames:GetChildren() do
        if frame:IsA('Frame') then
            if frame.Name == TargetFrame then
                frame.Visible = true
            else
                frame.Visible = false
            end
        end
    end
end

--> Main Functions
----------------------------------------

function EventsController:KnitStart()
    self.FoodBombEvent = Knit.GetService('FoodBomb')

    self.FoodBombEvent.EventStatus:Observe(function(txt)
        StatusTxt.Text = txt
    end)
    self.FoodBombEvent.EventSubStatus:Observe(function(txt)
        SubStatusTxt.Text = txt
    end)

    self.FoodBombEvent.WeightGained:Connect(function(Weight)
        Weight = RoundTo2DecimalPlaces(Weight)
        if Weight > 0 then
            ShortNotification("You gained " .. Weight .. "kg!", Color3.fromRGB(255, 0, 0),false)
            SoundEffects.BadFood:Play()
        elseif Weight < 0 then
            SoundEffects.SuperFood:Play()
            ShortNotification("You lost " .. Weight .. "kg!", Color3.fromRGB(0, 255, 0),false)
        end
    end)
end

return EventsController