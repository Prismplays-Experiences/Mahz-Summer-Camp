--> Services
----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lightning = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
-- local RunService = game:GetService("RunService")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")
local GeneralInfo = require("@Info/GeneralInfo")
local MarketService = require("@Modules/MarketService")
--> Assets
----------------------------------------
local Player = game.Players.LocalPlayer
local leaderstats = Player:WaitForChild("leaderstats")
local StrengthValue = leaderstats:WaitForChild("Strength")
local PlayerGui = Player.PlayerGui
local Main = PlayerGui:WaitForChild("Main")
local HUD = Main:WaitForChild("HUD")
local Core = Main:WaitForChild("Core")
local Timer = Core:WaitForChild("Timer")
local TargetStrengthTxt = Core:WaitForChild("TargetStrength")
local StrengthTxt = Core:WaitForChild("Strength")
local EnergyBoost = Core:WaitForChild("BoostPopup")
local EnergyBoostUIScale = EnergyBoost:WaitForChild("UIScale")

local Frames = Main:WaitForChild("Frames")
local TargetFrame = Frames:WaitForChild("TargetFrame")

local Models = ReplicatedStorage:WaitForChild("Models")
local SoundEffects = Models:WaitForChild("SoundEffects")

--> Variables
----------------------------------------
local MinutesPerDay = 6

--> Knit Setup
----------------------------------------
local GeneralControllers = Knit.CreateController({
	Name = "GeneralControllers",
})

--> Utility Functions
----------------------------------------
function SendNotification(msg, color, duration, reward, sound)
	local Notify = Knit.GetController("UINotificationsController")
	Notify:ShowNotification({
		message = msg,
		color = color or Color3.fromRGB(255, 255, 255),
		duration = duration or 2,
		reward = reward or false,
		sound = sound or SoundEffects.Positive,
	})
end

function TweenLightningClockTime(DesiredTime)
	local tinfo = TweenInfo.new(3.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local Tween = TweenService:Create(Lightning, tinfo, { ClockTime = DesiredTime })
	Tween:Play()
end

function OpenFrame(Frame, Pos)
	Frame.Position = Pos or Frame.Position
	local UIScale = Frame:FindFirstChild("UIScale") or Instance.new("UIScale")
	UIScale.Parent = Frame
	UIScale.Scale = 0

	local OpenTween = TweenService:Create(
		UIScale,
		TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
		{ Scale = 1 }
	)
	local CloseTween = TweenService:Create(
		UIScale,
		TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{ Scale = 0 }
	)

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

function TweenUiScale(UIScale, Value)
	TweenService:Create(UIScale, TweenInfo.new(1, Enum.EasingStyle.Back), { Scale = Value }):Play()
end

--> Main Functions
----------------------------------------

function GeneralControllers:KnitStart()
	local ClockService = Knit.GetService("ClockService")
	local GeneralGameplay = Knit.GetService("GeneralGameplay")
	local TargetService = Knit.GetService("TargetService")
	self.WorkoutsHandler = Knit.GetController("WorkoutsHandler")
	self.PlayerModule = require(
		game.Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule") :: ModuleScript
	):GetControls()
	ClockService:GetMinutesPerDay()
		:andThen(function(value)
			MinutesPerDay = value
		end)
		:await()
	local CurrentEmoji = "☀️"
	local START_HOUR = 8 -- 8 AM
	local END_HOUR = 22 -- 10 PM
	local HOUR_RANGE = END_HOUR - START_HOUR
	local TargetReached = false
	self.Day = 1
	print(MinutesPerDay)
	ClockService.Time:Observe(function(Value)
		local totalSecondsInDay = MinutesPerDay * 60
		local progress = math.clamp(Value / totalSecondsInDay, 0, 1)
		local currentHour = START_HOUR + (progress * HOUR_RANGE)
		local wholeMinutes = math.floor((currentHour - math.floor(currentHour)) * 60)
		local displayHour = math.floor(currentHour)
		if displayHour > 12 then
			displayHour -= 12
		elseif displayHour == 0 then
			displayHour = 12
		end
		if currentHour >= 18 then
			CurrentEmoji = "🌙"
			TweenLightningClockTime(21)
		else
			CurrentEmoji = "☀️"
		end
		Timer.Text = string.format("%s | %02d:%02d", CurrentEmoji, displayHour, wholeMinutes)
	end)

	function self.TransitionToDay()
		TweenLightningClockTime(14.5)
	end

	GeneralGameplay.EnableControls:Connect(function()
		self.PlayerModule:Enable()
	end)
	GeneralGameplay.DisableControls:Connect(function()
		self.PlayerModule:Disable()
	end)
	TargetService.DisplayTarget:Connect(function(Target, StrengthRequired, Day)
		TargetReached = false
		if StrengthValue.Value < StrengthRequired then
			StrengthRequired = math.clamp(StrengthRequired - Target / 2, GeneralInfo.Strength, math.huge)
		end
		self.Target = StrengthRequired
		HUD:WaitForChild("TargetStrength").Text = `Your Target: {StrengthRequired}💪`
		HUD:WaitForChild("TargetStrength").TextColor3 = Color3.fromRGB(253, 255, 133)
		Core:WaitForChild("Day").Text = `Day {Day}`
		TargetFrame:WaitForChild("Target").Text =
			`Lose {math.clamp(StrengthValue.Value - StrengthRequired, Target, math.huge)}💪`
		TargetFrame:WaitForChild("Header").Text = `Day {Day} target`
		self.Day = Day
		local Close = OpenFrame(TargetFrame)
		SoundEffects.Positive:Play()
		local Signal
		Signal = TargetFrame:WaitForChild("GO").MouseButton1Click:Connect(function()
			Close()
			Signal:Disconnect()
			task.wait(2)
			TweenUiScale(EnergyBoostUIScale, 1)
		end)
		TargetStrengthTxt.Text = `Your Target: {StrengthRequired}💪`
		self.WorkoutsHandler:ControlProximityPrompts(true)
	end)
	EnergyBoost:WaitForChild("No").MouseButton1Click:Connect(function()
		TweenUiScale(EnergyBoostUIScale, 0)
	end)
	EnergyBoost:WaitForChild("Yes").MouseButton1Click:Connect(function()
		MarketplaceService:PromptProductPurchase(Player, MarketService.ProductIds.DailyEnergyBoost.Id)
	end)

	ClockService.DayEnded:Connect(function()
		ClockService:GetMinutesPerDay()
			:andThen(function(value)
				MinutesPerDay = value
			end)
			:await()
	end)

	-- Strength Value Update
	StrengthTxt.Text = `Strength: {StrengthValue.Value}💪`
	TargetStrengthTxt.Text = `Your Target: {self.Target}💪`
	self.Target = self.Target or 0

	-- Update Strength Text

	StrengthTxt.Text = `Strength: {StrengthValue.Value}lbs`
	StrengthValue:GetPropertyChangedSignal("Value"):Connect(function()
		if StrengthValue.Value <= self.Target and not TargetReached then
			TargetReached = true
			HUD:WaitForChild("TargetStrength").TextColor3 = Color3.fromRGB(0, 255, 0)
			GeneralGameplay:TargetReached()
			SendNotification(`Target accomplished!`, Color3.fromRGB(0, 255, 0), 3, true, SoundEffects.Won)
		end
		StrengthTxt.Text = `Strength: {StrengthValue.Value}lbs`
	end)

	GeneralGameplay.CountdownValue:Observe(function(Value)
		if Value > 1 then
			Main:WaitForChild("StartCountdown").Visible = true
			Main:WaitForChild("StartCountdown").Text = `Starting in {Value}`
			HUD.Visible = false
			Core.Visible = false
		else
			Main:WaitForChild("StartCountdown").Visible = false
			HUD.Visible = true
			Core.Visible = true
			self.WorkoutsHandler:ControlProximityPrompts(true)
		end
	end)
	game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)
end

return GeneralControllers
