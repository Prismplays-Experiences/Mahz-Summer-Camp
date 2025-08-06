--> Services
----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

--> Modules
----------------------------------------
local Signal = require("@Packages/Signal")

--> Assets
----------------------------------------
local Assets = ReplicatedStorage:WaitForChild("Assets")
Assets:WaitForChild("Minigames")

local Models = ReplicatedStorage:WaitForChild("Models")
local SoundEffects = Models:WaitForChild("SoundEffects")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main")
local GameplayFrames = Main:WaitForChild("Gameplay")

local Confetti = Assets:WaitForChild("Confetti")

--> Utility Functions
----------------------------------------

function ShortNotification(Text, TextColor)
	local NotificationTemplete = Confetti:WaitForChild("ShortNotification"):Clone()
	local UIStroke = NotificationTemplete:WaitForChild("UIStroke")
	NotificationTemplete.Text = Text
	NotificationTemplete.TextColor3 = TextColor or Color3.fromRGB(255, 255, 255)
	NotificationTemplete.Visible = false
	NotificationTemplete.Parent = GameplayFrames
	local tweeninstroke = TweenService:Create(UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { Transparency = 0 })
	local tweenintext =
		TweenService:Create(NotificationTemplete, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { TextTransparency = 0 })
	local tweentextpos = TweenService:Create(
		NotificationTemplete,
		TweenInfo.new(1.6, Enum.EasingStyle.Quad),
		{ Position = UDim2.fromScale(0.5, NotificationTemplete.Position.Y.Scale - 0.35) }
	)
	local tweenoutstroke =
		TweenService:Create(UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { Transparency = 1 })
	local tweenouttext =
		TweenService:Create(NotificationTemplete, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { TextTransparency = 1 })
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

--> Main Functions
----------------------------------------

local ProgressBarController = {}
ProgressBarController.__index = ProgressBarController

function ProgressBarController:new(Bar)
	self = setmetatable({}, ProgressBarController)

	self.ProgressValue = Instance.new("NumberValue")
	self.Bar = Bar
	self.Failed = Signal.new()
	self.Stopped = Signal.new()
	self.Status = ""
	self.DecreaseMultiplier = 1
	self.DecreaseDefault = 0.005

	return self
end

function ProgressBarController:ApplyScreenColorFlash(isCorrect, func)
	if self.ScreenFlashPlaying then
		return
	end
	self.ScreenFlashPlaying = true
	-- Reuse or create the effect
	local effect = Lighting:FindFirstChild("ResultColorEffect")
	if not effect then
		effect = Instance.new("ColorCorrectionEffect")
		effect.Name = "ResultColorEffect"
		effect.Parent = Lighting
	end

	local sound = isCorrect and SoundEffects.Correct or SoundEffects.Alarm
	effect.TintColor = isCorrect and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
	effect.Brightness = 0
	effect.Contrast = 0
	effect.Saturation = 0

	local tweenIn = TweenService:Create(effect, TweenInfo.new(0.15), { Brightness = 0.15 })
	local tweenOut = TweenService:Create(effect, TweenInfo.new(0.4, Enum.EasingStyle.Quad), { Brightness = 0 })

	tweenIn:Play()
	sound:Play()
	if func then
		task.spawn(func)
	end
	tweenIn.Completed:Connect(function()
		tweenOut:Play()
	end)

	tweenOut.Completed:Connect(function()
		effect:Destroy()
		task.wait(0.5)
		self.ScreenFlashPlaying = false
	end)
end

function RandomItem(Folder, PreviousItem)
	local Item
	repeat
		Item = Folder[math.random(1, #Folder)]
	until Item and Item ~= PreviousItem
	return Item
end

local PositiveMessages = {
	{ "Excellent work!" },
	{ "Good job!" },
	{ "You are crushing it!" },
}

function ProgressBarController:SendPositiveMessage()
	if self.PositiveMessageDb then
		return
	end
	self.PositiveMessageDb = true
	if self.PositiveMessageStatus >= 3 then
		task.delay(3, function()
			self.PositiveMessageStatus = 0
			self.PositiveMessageDb = false
		end)
		return
	end
	self.PositiveMessageStatus += 1
	local msg = RandomItem(PositiveMessages, self.previousmsg)
	if not msg then
		self.PositiveMessageDb = false
		return
	end
	self.previousmsg = msg
	ShortNotification(msg[1], Color3.fromRGB(0, 255, 0))
	task.wait(1)
	self.PositiveMessageDb = false
end

function ProgressBarController:Update()
	task.spawn(function()
		if self.ProgressValue.Value <= 0.2 then
			local function negative()
				ShortNotification("warning!", Color3.fromRGB(255, 0, 0))
			end
			self:ApplyScreenColorFlash(false, negative)
		end

		if self.ProgressValue.Value >= 0.75 then
			self:SendPositiveMessage()
		end
	end)
	if self.ProgressValue.Value <= 0.2 then
		if not self.JustFired then
			self.JustFired = true
			self.Failed:Fire(true)
			task.wait(2.5)
			self.JustFired = false
		end
	else
		if not self.JustFired then
			self.JustFired = true
			self.Failed:Fire(false)
			task.delay(2.5, function()
				self.JustFired = false
			end)
		end
	end
	self.ProgressValue.Value = math.clamp(self.ProgressValue.Value, 0, 1)
	local targetPosition = UDim2.fromScale(0.5, 1 - self.ProgressValue.Value)
	local bar = self.Bar:WaitForChild("Bar")
	local tweenInfo = TweenInfo.new(
		0.1, -- Time
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	local tween = TweenService:Create(bar, tweenInfo, {
		Position = targetPosition,
	})
	tween:Play()
end

function ProgressBarController:Start(Stop)
	if self._isUpdating then
		return
	end
	self.PositiveMessageStatus = 0
	self._isUpdating = true
	self.ProgressValue.Value = 0.5
	-- self.DecreaseMultiplier = 1
	-- self.DecreaseDefault = 0.005
	self:Update()

	--      RunService:BindToRenderStep(
	-- 'ProgressBarUpdate',
	-- Enum.RenderPriority.Input.Value + 1,
	-- function()
	-- if not self.Incremented then return end
	-- local val = math.clamp(self.DecreaseDefault*self.DecreaseMultiplier, 0, 1)
	-- self.ProgressValue.Value -= val
	-- self:Update()
	-- end)

	self._isUpdating = true

	if self._progressThread then
		return
	end

	self._progressThread = task.spawn(function()
		repeat
			wait()
		until self.Incremented
		while self.Incremented do
			local rate = math.clamp(self.DecreaseDefault * self.DecreaseMultiplier, 0, 1) - self.IncrementedAmount or 0
			self.IncrementedAmount = 0
			self.ProgressValue.Value -= rate
			self:Update()
			task.wait() -- adjust this interval for responsiveness (e.g. 0.05 or 0.2)
		end

		self._progressThread = nil
	end)

	Stop:Connect(function()
		self:Stop()
	end)
end

function ProgressBarController:Stop()
	self.Incremented = false
	if not self._isUpdating then
		return
	end

	self._progressThread = nil
	self._isUpdating = false
	self.ProgressValue.Value = 0.5
	self.Stopped:Fire()
	RunService:UnbindFromRenderStep("ProgressBarUpdate")
end

function ProgressBarController:AdjustSpeed(Amount)
	self.DecreaseMultiplier = math.clamp(self.DecreaseMultiplier + Amount, 0.75, 2)
end

function ProgressBarController:Increment(Amount)
	self.Incremented = true
	Amount = math.clamp(Amount, 0.01, 1)
	if not self._isUpdating then
		self:Start()
	end
	local val = math.clamp(Amount + self.ProgressValue.Value, 0, 1)
	-- self.ProgressValue.Value = val
	self.IncrementedAmount = val
end

return ProgressBarController
