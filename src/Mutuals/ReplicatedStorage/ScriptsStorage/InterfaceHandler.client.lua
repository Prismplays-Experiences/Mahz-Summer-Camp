
--> Services
----------------------------------------
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local SocialService = game:GetService("SocialService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")


--> Modules
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local ProductDisplay = require(Modules:WaitForChild('ProductDisplay'))
local Utils = Modules:WaitForChild("Utils")
local ClientModules = Modules:WaitForChild("Client")

local Knit = require(Packages:WaitForChild("Knit"))
local confettiParticles = require(ClientModules:WaitForChild("ConfettiParticles"))
local MarketModule = require(Modules:WaitForChild("MarketService"))
local MouseMovement = require(Modules:WaitForChild("GuiPresets")).MouseMovement
local animPlugin = require(Utils:WaitForChild("Spr"))

local CustomModules = ReplicatedStorage:WaitForChild('CustomModules')
local ZoneConnect = require(CustomModules:WaitForChild('ZoneConnect'))

--> Assets
----------------------------------------
local SoundEffects = ReplicatedStorage:WaitForChild("Models"):WaitForChild("SoundEffects")
local ScriptingProperties = workspace:WaitForChild('Game'):WaitForChild('ScriptingProperties')
-- local ZonePoints = ScriptingProperties:WaitForChild('ZonePoints')
-- local WheelZone = ZonePoints:WaitForChild('Wheel')
-- local ShopZone = ZonePoints:WaitForChild('Shop')
-- local GroupZone = ZonePoints:WaitForChild('GroupChest')

local Assets = ReplicatedStorage:WaitForChild("Assets")

local blur = Lighting:FindFirstChild("UIBlur") or Instance.new("BlurEffect", Lighting)
blur.Name = "UIBlur"
blur.Size = 0

--> Variables
----------------------------------------
local Player = Players.LocalPlayer
local DataLoaded = Player:WaitForChild("DataLoaded")
repeat task.wait() until 
DataLoaded.Value == true

local camera = workspace.CurrentCamera
local platform = (UserInputService.GamepadEnabled and "Console") or (UserInputService.TouchEnabled and "Mobile") or "Pc"


--> Interfaces
----------------------------------------
local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main")
local HUD = Main:WaitForChild("HUD")
local Buttons = HUD:WaitForChild("Buttons")
local Frames = Main:WaitForChild("Frames")

-- local DailyFrame = Frames:WaitForChild("Daily")
local WheelFrame = Frames:WaitForChild("Wheel")
local TrailsFrame = Frames:WaitForChild("Trails")
local BalloonShop = Frames:WaitForChild("Balloons")


local FramesTable = {
    -- DailyFrame,
    WheelFrame,
    BalloonShop,
	TrailsFrame,
}



--> Utility Functions
----------------------------------------

function SendNotification(msg,color,duration,reward,sound)
    local Notify = Knit.GetController('UINotificationsController')
    Notify:ShowNotification({
        message = msg,
        color = color or Color3.fromRGB(255, 255, 255),
        duration = duration or 2,
        reward = reward or false,
        sound = sound or SoundEffects.Positive})
end


function SpinEffect(Model, RotationSpeed)
	if not Model or not Model:IsA("Model") then return end

	local Connection
	local pivotCFrame = Model:GetPivot()

	Connection = RunService.Stepped:Connect(function(_, deltaTime)
		local rotation = CFrame.Angles(math.rad(RotationSpeed * deltaTime), 0, 0)
		pivotCFrame = pivotCFrame * rotation
		Model:PivotTo(pivotCFrame)
	end)

	return function()
		if Connection then
			Connection:Disconnect()
			Connection = nil
		end
	end
end

local function Tween(item, prop, goal, speed, style)
    local TInfo = TweenInfo.new(speed, style)
    TweenService:Create(item, TInfo, {[prop] = goal}):Play()
end

local function BtnMovement(btn)
    if btn.Name == "Play" then return end
    if btn:IsA("GuiButton") then
        MouseMovement(true, btn, true, nil, nil, nil, SoundEffects)
        MouseMovement(true, btn, false, nil, 0.95, nil, SoundEffects)
    end
end

local function OpenFrame(Frame, Pos)
    Frame.Position = Pos or Frame.Position
    local UIScale = Frame:FindFirstChild("UIScale") or Instance.new("UIScale", Frame)
    UIScale.Scale = 0

    local OpenTween = TweenService:Create(UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Scale = 1})
    local CloseTween = TweenService:Create(UIScale, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Scale = 0})

    OpenTween:Play()
    Frame.Visible = true

    local function Close()
        CloseTween:Play()
        CloseTween.Completed:Once(function()
            Frame.Visible = false
        end)
    end

    return Close
end

local function UIMovement(show, frame, speed)
    if not frame then return end
    frame.ZIndex = show and 50 or 49

    local blur = Lighting:FindFirstChild("UIBlur") or Instance.new("BlurEffect", Lighting)
    blur.Name = "UIBlur"
    animPlugin.target(blur, 1, 2, {Size = show and 15 or 0})
    frame.Visible = show
end

local function GetCanvasPosition(scroller, DesiredFrame)
    local difference = DesiredFrame.AbsolutePosition - scroller.AbsolutePosition
    return scroller.CanvasPosition + difference
end


--> Main Functions
----------------------------------------
local function InvitePrompt()
    local success, canInvite = pcall(function()
        return SocialService:CanSendGameInviteAsync(Player)
    end)
    if success and canInvite then
        SocialService:PromptGameInvite(Player)
    end
end

local function ToggleControl(btn, Frame, canvaspos)
    task.spawn(function()
        UIMovement(false, Frame)
        local Status = Frame.Visible
        local Debounce = false

        btn.MouseButton1Click:Connect(function()
            if Debounce then return end
            Debounce = true

            SoundEffects.MobileToogle:Play()

            if not Status then
                animPlugin.target(camera, 0.5, 3, {FieldOfView = 85})
                animPlugin.target(blur, 0.5, 3, {Size = 15})
                if Frame.Name == "Wheel" then
                    HUD.Visible = false
                else
                    HUD.Visible = true
                end
            else
                animPlugin.target(camera, 0.5, 3, {FieldOfView = 70})
                animPlugin.target(blur, 0.5, 3, {Size = 0})
                HUD.Visible = true
            end

            if Status then
                UIMovement(false, Frame)
            else
                for _, v in ipairs(FramesTable) do
                    if v ~= Frame then
                        task.spawn(function()
                            UIMovement(false, v)
                        end)
                    end
                end
                UIMovement(true, Frame)
                if canvaspos then
                    TweenService:Create(Frame:WaitForChild("InnerFrame"):WaitForChild("ScrollingFrame"), TweenInfo.new(0.7), {
                        CanvasPosition = canvaspos
                    }):Play()
                end
            end

            Status = not Status
            task.wait()
            Debounce = false
        end)

        Frame:GetPropertyChangedSignal("Visible"):Connect(function()
            Status = Frame.Visible
        end)
    end)
end


--> Connections
----------------------------------------
for _, v in pairs(PlayerGui:GetDescendants()) do
    if v:IsA("GuiButton") and v.Parent.Parent.Name ~= "Buttons" then
        BtnMovement(v)
    end
end

Buttons.Invite.MouseButton1Click:Connect(InvitePrompt)

-- script:WaitForChild("DailyRewardToogle").Event:Connect(function()
--     UIMovement(true, DailyFrame)
--     local blur = Lighting:FindFirstChild("UIBlur")
--     animPlugin.target(blur, 1, 2, {Size = 24})
--     animPlugin.target(camera, 1, 2, {FieldOfView = 60})
-- end)

Player.Idled:Connect(function(time)
    if time > 1150 then
        pcall(function()
            TeleportService:Teleport(game.PlaceId, Player)
        end)
    end
end)

local Cash = Player:WaitForChild("PrivateStats"):WaitForChild("Currency")
local CashLabel = HUD:WaitForChild("CashCounter"):WaitForChild('Amount')

local TweenCash = Instance.new("IntValue")
TweenCash.Value = Cash.Value
TweenCash.Parent = script

local function Comma(n)
	return tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function UpdateText(val)
	CashLabel.Text = Comma(val)
end

Cash:GetPropertyChangedSignal("Value"):Connect(function()
	TweenService:Create(TweenCash, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {Value = Cash.Value}):Play()
end)

TweenCash:GetPropertyChangedSignal("Value"):Connect(function()
	UpdateText(TweenCash.Value)
end)

UpdateText(Cash.Value)



--> Start
----------------------------------------
-- local Scroller = ShopFrame:WaitForChild("InnerFrame"):WaitForChild("ScrollingFrame")

task.spawn(function()
    -- ToggleControl(Main:WaitForChild("ExternalUIs").Cash:WaitForChild("Add"), ShopFrame, GetCanvasPosition(Scroller, Scroller:WaitForChild("CashHeading")))
    -- ToggleControl(Buttons.Shop, BalloonShop)
    ToggleControl(BalloonShop.Close, BalloonShop)

    -- ToggleControl(Buttons.Daily, DailyFrame)
    -- ToggleControl(DailyFrame.Close, DailyFrame)

    ToggleControl(WheelFrame.Close, WheelFrame)
    ToggleControl(Buttons.Wheel, WheelFrame)

	ToggleControl(TrailsFrame.Close, TrailsFrame)
    ToggleControl(Buttons.Trails, TrailsFrame)
end)

local SurfaceUIS = PlayerGui:WaitForChild("SurfaceUI")
local JoinButton = SurfaceUIS:WaitForChild('JoinStand'):WaitForChild('Join')
JoinButton.MouseButton1Click:Connect(function()
    MarketplaceService:PromptProductPurchase(Player, MarketModule.ProductIds.Revive.Id)
end)

--> Zones
----------------------------------------

-- ZoneConnect:new(ShopZone, 
--     function()
--         for i,v in FramesTable do
--             if v == ShopFrame then continue end
--             task.spawn(function()
--                 UIMovement(false,v)
--             end)
--         end
--         animPlugin.target(camera, 0.5, 3, {FieldOfView = 85})
--         animPlugin.target(blur, 0.5, 3, {Size = 15})
--         UIMovement(true,ShopFrame)
--     end,

--     function()
--         animPlugin.target(camera, 0.5, 3, {FieldOfView = 70})
--         animPlugin.target(blur, 0.5, 3, {Size = 0})
--         UIMovement(false,ShopFrame)
--     end, Player

-- )

-- ZoneConnect:new(WheelZone, 
--     function()
--         for i,v in FramesTable do
--             if v == WheelFrame then continue end
--             task.spawn(function()
--                 UIMovement(false,v)
--             end)
--         end
--         animPlugin.target(camera, 0.5, 3, {FieldOfView = 85})
--         animPlugin.target(blur, 0.5, 3, {Size = 15})
--         UIMovement(true,WheelFrame)
--     end,

--     function()
--         animPlugin.target(camera, 0.5, 3, {FieldOfView = 70})
--         animPlugin.target(blur, 0.5, 3, {Size = 0})
--         UIMovement(false,WheelFrame)
--     end,Player
-- )

-- local DailyRewardController = Knit.GetController('DailyRewardController')
-- DailyRewardController.RewardToogle:Connect(function()
--     for i,v in FramesTable do
--         if v == DailyFrame then continue end
--         task.spawn(function()
--             UIMovement(false,v)
--         end)
--     end
--     animPlugin.target(camera, 0.5, 3, {FieldOfView = 85})
--     animPlugin.target(blur, 0.5, 3, {Size = 15})
--     UIMovement(true,DailyFrame)
-- end)

--> Workspace Handler
----------------------------------------
-- local DisplayItems = Assets:WaitForChild("DisplayItems")

-- local ProductToDisplay = {}

-- for _,v in pairs(MarketModule.GamepassIds) do
--     if _ == 'VIP' then v.ToolName = "VIP" end
--     if v.ToolName then
--         ProductToDisplay[_] = {
--             model = DisplayItems:FindFirstChild(v.ToolName):Clone(),
--             id = v.Id,
--             itemType = "Gamepass",
--             movement = DisplayItems:FindFirstChild(v.ToolName):GetAttribute("Movement") or "SpinAndBob"
--         }
--     end
-- end

-- ProductDisplay.new(ProductToDisplay)


-- local WheelModel = ScriptingProperties:WaitForChild('WheelModel')
-- SpinEffect(WheelModel,20)

--> Group Reward
----------------------------------------
-- local GroupRewardService = Knit.GetService('GroupRewardService')
-- ZoneConnect:new(GroupZone,
--     function()
--         GroupRewardService:ClaimReward():andThen(function(Result, Msg)
--             if not Result then
--              SendNotification(Msg, Color3.fromRGB(255,0,0),2,false,SoundEffects.UIDeny)
--             end
--         end)

--     end,nil,Player
-- )