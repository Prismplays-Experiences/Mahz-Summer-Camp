--> Services
----------------------------------------
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local SocialService = game:GetService("SocialService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

--> Modules
----------------------------------------
local MarketModule = require("@Modules/MarketService")
local MouseMovement = require("@Modules/GuiPresets").MouseMovement
local animPlugin = require("@Modules/Utils/Spr")

--> Assets
----------------------------------------
local SoundEffects = ReplicatedStorage:WaitForChild("Models"):WaitForChild("SoundEffects")

local blur = Lighting:FindFirstChild("UIBlur") or Instance.new("BlurEffect")
blur.Parent = Lighting
blur.Name = "UIBlur"
blur.Size = 0

--> Variables
----------------------------------------
local Player = Players.LocalPlayer
local DataLoaded = Player:WaitForChild("DataLoaded")
repeat
	task.wait()
until DataLoaded.Value == true

local camera = workspace.CurrentCamera

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

local function BtnMovement(btn)
	if btn.Name == "Play" then
		return
	end
	if btn:IsA("GuiButton") then
		MouseMovement(true, btn, true, nil, nil, nil, SoundEffects)
		MouseMovement(true, btn, false, nil, 0.95, nil, SoundEffects)
	end
end

local function UIMovement(show, frame)
	if not frame then
		return
	end
	frame.ZIndex = show and 50 or 49

	local blurMovement = Lighting:FindFirstChild("UIBlur") or Instance.new("BlurEffect")
	blurMovement.Parent = Lighting
	blurMovement.Name = "UIBlur"
	animPlugin.target(blurMovement, 1, 2, { Size = show and 15 or 0 })
	frame.Visible = show
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
			if Debounce then
				return
			end
			Debounce = true

			SoundEffects.MobileToogle:Play()

			if not Status then
				animPlugin.target(camera, 0.5, 3, { FieldOfView = 85 })
				animPlugin.target(blur, 0.5, 3, { Size = 15 })
				if Frame.Name == "Wheel" then
					HUD.Visible = false
				else
					HUD.Visible = true
				end
			else
				animPlugin.target(camera, 0.5, 3, { FieldOfView = 70 })
				animPlugin.target(blur, 0.5, 3, { Size = 0 })
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
					TweenService
						:Create(Frame:WaitForChild("InnerFrame"):WaitForChild("ScrollingFrame"), TweenInfo.new(0.7), {
							CanvasPosition = canvaspos,
						})
						:Play()
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
local CashLabel = HUD:WaitForChild("CashCounter"):WaitForChild("Amount")

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
	TweenService:Create(TweenCash, TweenInfo.new(0.75, Enum.EasingStyle.Quad), { Value = Cash.Value }):Play()
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
local JoinButton = SurfaceUIS:WaitForChild("JoinStand"):WaitForChild("Join")
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
