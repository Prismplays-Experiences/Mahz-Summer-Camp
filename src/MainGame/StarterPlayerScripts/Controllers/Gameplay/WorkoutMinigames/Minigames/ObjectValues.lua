--> Services
----------------------------------------
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local Lighting = game:GetService('Lighting')
local TweenService = game:GetService('TweenService')
local CollectionService = game:GetService("CollectionService")

--> Modules
----------------------------------------
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Utils = Modules:WaitForChild('Utils')
local SpringMotion = require(Utils:WaitForChild('Spr'))

local Packages = ReplicatedStorage:WaitForChild('Packages')
local Signal = require(Packages:WaitForChild('Signal'))
local Knit = require(Packages:WaitForChild('Knit'))

local ProgressBarController = require(script.Parent.Parent:WaitForChild('Progressbar'))

local Info = ReplicatedStorage:WaitForChild('Info')
local MinigamesInfo = Info:WaitForChild('Minigames')
local ObjectValuesInfo = require(MinigamesInfo:WaitForChild('ObjectValuesInfo'))

--> Assets
----------------------------------------
local Assets = ReplicatedStorage:WaitForChild('Assets')
local Minigames = Assets:WaitForChild('Minigames')

local Models = ReplicatedStorage:WaitForChild('Models')
local SoundEffects = Models:WaitForChild('SoundEffects')

local PlayerGui = Players.LocalPlayer:WaitForChild('PlayerGui')
local Main = PlayerGui:WaitForChild('Main')
local GameplayFrames = Main:WaitForChild('Gameplay')
local ObjectsGameplay = GameplayFrames:WaitForChild('ObjectsGameplay')
local ObjectsHolder = ObjectsGameplay:WaitForChild('ObjectsHolder')
local ProgressBar = ObjectsGameplay:WaitForChild('ProgressBar')
local ExitMachine = ObjectsGameplay:WaitForChild('ExitMachine')
local CurrentTarget = ObjectsGameplay:WaitForChild('CurrentTarget')

local ObjectValuesItems = Minigames:WaitForChild('ObjectValuesItems')
local Confetti = Assets:WaitForChild('Confetti')



--> Variables
----------------------------------------


--> Knit Setup
----------------------------------------
local ObjectValuesMinigame = Knit.CreateController {
    Name = 'ObjectValuesMinigame',
    TargetObject = '',
    Speed = 2.5,
    ThrowRate = 1,
    StopEvent = Signal.new(),
}


--> Utility Functions
----------------------------------------
function ApplyTargetProperties(Text,Img)
    local UIScale = CurrentTarget:FindFirstChild('UIScale') or Instance.new('UIScale', CurrentTarget)
    UIScale.Scale = 1
    local tweenOut = TweenService:Create(UIScale, 
        TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), 
        { Scale = 0 }
    )
    local tweenIn = TweenService:Create(UIScale, 
        TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), 
        { Scale = 1 }
    )

    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        CurrentTarget.Text = Text
        if Img then
            CurrentTarget:WaitForChild('ImageLabel').Image = Img
        end
        tweenIn:Play()
        SoundEffects.Positive:Play()
    end)

end

function ShortNotification(Text,TextColor,Sound)
    local NotificationTemplete = Confetti:WaitForChild('ShortNotification'):Clone()
    local UIStroke = NotificationTemplete:WaitForChild('UIStroke')
    NotificationTemplete.Text = Text
    NotificationTemplete.TextColor3 = TextColor or Color3.fromRGB(255, 255, 255)
    NotificationTemplete.Visible = false
    NotificationTemplete.Parent = ObjectsGameplay
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

--> Main Functions
----------------------------------------

function ObjectValuesMinigame:ApplyScreenColorFlash(isCorrect)
    -- Reuse or create the effect
    local effect = Lighting:FindFirstChild("ResultColorEffect")
    if not effect then
        effect = Instance.new("ColorCorrectionEffect")
        effect.Name = "ResultColorEffect"
        effect.Parent = Lighting
    end

    local sound = isCorrect and SoundEffects.Correct or SoundEffects.Wrong
    effect.TintColor = isCorrect and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    effect.Brightness = 0
    effect.Contrast = 0
    effect.Saturation = 0

    local tweenIn = TweenService:Create(effect, TweenInfo.new(0.15), { Brightness = 0.15 })
    local tweenOut = TweenService:Create(effect, TweenInfo.new(0.4, Enum.EasingStyle.Quad), { Brightness = 0 })
    
    tweenIn:Play()
    sound:Play()
    tweenIn.Completed:Connect(function()
        tweenOut:Play()
    end)

    tweenOut.Completed:Connect(function()
        effect:Destroy() -- Remove if you want a clean reset
    end)
end

function DestroyObject(obj)
    local UIScale = obj:FindFirstChild('UIScale') or Instance.new('UIScale', obj)
    UIScale.Scale = 1

    local ScaleDownTween = TweenService:Create(UIScale, 
        TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), 
        { Scale = 0 }
    )
    ScaleDownTween:Play()
    ScaleDownTween.Completed:Wait()
    obj:Destroy()
end

local PreviousObject = nil
function RandomItem(Folder, PreviousItem)
    if typeof(Folder) == "string" then
        Folder = { Folder }
    end

    local items = {}

    if typeof(Folder) == "table" then
        local isArray = #Folder > 0
        if isArray then
            items = Folder
        else
            -- Add values instead of keys
            for _, value in pairs(Folder) do
                table.insert(items, value)
            end
        end
    elseif typeof(Folder) == "Instance" and Folder.GetChildren then
        items = Folder:GetChildren()
    end

    if #items == 0 then return nil end
    if #items == 1 then return items[1] end

    local Item
    repeat
        Item = items[math.random(1, #items)]
    until Item ~= PreviousItem
    return Item
end





function GetRandomSignedValue(value)
    return math.random() * 2 * value - value
end

--> Main Functions
----------------------------------------

function ObjectValuesMinigame:ThrowObject(targetFrame)
    local UIScale = targetFrame:FindFirstChild('UIScale') or Instance.new('UIScale', targetFrame)
    UIScale.Scale = 0

    local UIScaleTween = TweenService:Create(UIScale, 
        TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), 
        { Scale = 1 }
    )

    local UIScaleTweenOut = TweenService:Create(UIScale, 
        TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), 
        { Scale = 0 }
    )


    if typeof(self.TargetObject) == "table" then
        if table.find(self.TargetObject, targetFrame.Name) then
            CollectionService:AddTag(targetFrame, "Correct")
        end
    else
        if targetFrame.Name == self.TargetObject then
            CollectionService:AddTag(targetFrame, "Correct")
        end
    end
    local isActive = true
    local clicked = false
    local speedIncrement = 0.05
    local throwRateIncrement = 0.05

    if targetFrame:IsA("ImageButton") or targetFrame:IsA("TextButton") then
        targetFrame.MouseButton1Down:Connect(function()
            if isActive then
                isActive = false
                clicked = true

                if CollectionService:HasTag(targetFrame, "Correct") then
                    speedIncrement = -0.02
                    throwRateIncrement = -0.02
                    self.BarControl:Increment(math.random(3,8)/10)
                    self:ApplyScreenColorFlash(true)
                else
                    self:ApplyScreenColorFlash(false)
                end
                self.Speed += speedIncrement
                self.ThrowRate = math.clamp(self.ThrowRate + throwRateIncrement, 0.8, 2)
                if self.ThrowRate>1.5 or self.Speed< 1 then
                    ShortNotification('FASTER!!', Color3.fromRGB(255, 38, 0))
                end
                isActive = false
            end
        end)
    end

        -- Physics simulation loop
    task.delay(0.01, function()
        UIScaleTween:Play()
    end)
    coroutine.wrap(function()
        targetFrame.Position = UDim2.fromScale(math.random(0,100)/100, 0)
        local startTime = tick()
        local duration = self.Speed
        local startPos = targetFrame.Position
        local endyaxis = startPos.Y.Scale+0.1
        local endPos = UDim2.new(math.clamp(startPos.X.Scale + GetRandomSignedValue(0.4),0,1), 0,endyaxis, 0)
        local peakHeight = 1
        local rotation = math.random(-180,180)

        while isActive do
            local elapsed = tick() - startTime
            local t = elapsed / duration
            if t > 1 then break end

            -- Parabolic arc: y = 4h * (t - 0.5)^2 - h
            local arcY = 4 * peakHeight * (t - 0.5)^2 + endyaxis

            local currentX = startPos.X.Scale + (endPos.X.Scale - startPos.X.Scale) * t
            targetFrame.Rotation = rotation * t
            targetFrame.Position = UDim2.new(currentX, 0, arcY, 0)

            RunService.RenderStepped:Wait()
            -- if endyaxis+0.1 > targetFrame.Position.Y.Scale then
            --     isActive = false
            -- end
        end
        UIScaleTweenOut:Play()
        UIScaleTweenOut.Completed:Wait()
        targetFrame:Destroy()
        if not clicked and CollectionService:HasTag(targetFrame, "Correct") then
            self.Speed += speedIncrement
            self.ThrowRate = math.clamp(self.ThrowRate + throwRateIncrement, 0.8, 2)
        end

        -- if isActive then
        --     targetFrame.Position = endPos
        -- end
    end)()
end




function ObjectValuesMinigame:Level_1_Gameplay()
    self.BarControl.DecreaseDefault = 0.0025
    local NewTarget = RandomItem(ObjectValuesInfo.nonjunkfood.Items,PreviousObject)
    -- PreviousObject = NewTarget
    self.TargetObject = NewTarget
    local Item = ObjectValuesItems:FindFirstChild(NewTarget)
    ApplyTargetProperties(`Tap the {NewTarget}`, Item.Image)
end

function ObjectValuesMinigame:Level_2_Gameplay()
    self.BarControl.DecreaseDefault = 0.005
    local NewTarget = RandomItem(ObjectValuesInfo,PreviousObject)
    PreviousObject = NewTarget
    self.TargetObject = NewTarget.Items
    ApplyTargetProperties(NewTarget.Description, NewTarget.Img)
end

function ObjectValuesMinigame:TargetItemControl(Level)
    if Level == 1 then
        while self.Throwing do
            self:Level_1_Gameplay(true)
            local waitTime = math.random(10, 20)
            local startTime = tick()

            while tick() - startTime < waitTime do
                if not self.Throwing then return end
                task.wait(0.1)
            end
        end
    elseif Level == 2 then
        while self.Throwing do
            local Choice = math.random(1, 3)
            if Choice == 1 then
                                self:Level_1_Gameplay(true)
                -- self:Level_1_Gameplay(true)
            else
                self:Level_2_Gameplay(true)
            end
            local waitTime = math.random(12, 25)
            local startTime = tick()

            while tick() - startTime < waitTime do
                if not self.Throwing then return end
                task.wait(0.1)
            end
        end
    end
    print(self.Throwing)
end

function ObjectValuesMinigame:Start(Level)
    if self.Throwing then return end
    self.BarControl:Start(self.StopEvent)
    ObjectsGameplay.Visible = true
    self.Throwing = true
    local rate = self.ThrowRate or 1
    task.spawn(function()
        self:TargetItemControl(Level)
    end)
    repeat task.wait() until self.Target ~= ''

    self.Correctrate = 0
    task.spawn(function()
        while self.Throwing do
            local clone
            if self.Correctrate >= 2 then
                task.delay(math.random(1,3), function()
                    self.Correctrate = 0
                end)
                clone = RandomItem(ObjectValuesItems):Clone()
            else
                self.Correctrate+=1
                local objstringname = ObjectValuesItems:FindFirstChild(RandomItem(self.TargetObject))
                clone = objstringname:Clone()
            end
            clone.AnchorPoint = Vector2.new(0.5, 0.5)
            clone.Parent = ObjectsHolder
            self:ThrowObject(clone)
            task.wait(rate)
        end
    end)
    local Data = {
        Stopped = self.BarControl.Stopped,
        Failed = self.BarControl.Failed,
        Value = self.BarControl.ProgressValue,
        Stop = self.StopEvent,
    }
    return Data
end

function ObjectValuesMinigame:Stop()
    self.Throwing = false
    ObjectsGameplay.Visible = false
    ObjectsHolder:ClearAllChildren()
    self.BarControl:Stop()
    self.TargetObject = ''
    self.ThrowRate = 1
    self.Speed = 2.5
end

function ObjectValuesMinigame:KnitInit()
    self.BarControl = ProgressBarController:new(ProgressBar)
    
    ExitMachine.MouseButton1Click:Connect(function()
        self:Stop()
    end)
    self.StopEvent:Connect(function()
        self:Stop()
    end)
end

return ObjectValuesMinigame