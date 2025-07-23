--> Services
----------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--> Knit Setup
----------------------------------------
local Knit = require("@Packages/Knit")
local Signal = require("@Packages/Signal")
local DailyRewardController = Knit.CreateController({
	Name = "DailyRewardController",
	RewardToggle = Signal.new(),
})

--> Assets
----------------------------------------
local SoundEffects = ReplicatedStorage:WaitForChild("Models"):WaitForChild("SoundEffects")

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

local function toHMS(s)
	return string.format("%02i:%02i:%02i", s / 60 ^ 2, s / 60 % 60, s % 60)
end

local function getPlatform()
	if UserInputService.TouchEnabled then
		return "Mobile"
	end
	if UserInputService.KeyboardEnabled then
		return "Pc"
	end
	return "Console"
end

local function RewardAvailableEffect(ui, timerText)
	task.spawn(function()
		ui.Visible = true
		timerText.Text = "Ready!"
		timerText.TextColor3 = Color3.fromRGB(0, 239, 0)
	end)
end

local function EnableClaim(btn)
	pcall(function()
		btn:WaitForChild("Alert").Visible = true
		btn.CanClaim.Value = true
		btn.Claimed.Visible = false
	end)
end

local function EnableClaimed(btn)
	pcall(function()
		btn.Alert.Visible = false
		btn.CanClaim.Value = false
		btn.Claimed.Visible = true
	end)
end

local function LockReward(btn)
	btn.Alert.Visible = false
end

--> Main Function
----------------------------------------
function DailyRewardController:Blub() -- KnitStart()
	local Player = Players.LocalPlayer
	if not game.Loaded then
		game.Loaded:Wait()
	end
	repeat
		task.wait()
	until Player:FindFirstChild("DataLoaded") and Player.DataLoaded.Value

	local RewardService = Knit.GetService("RewardService")

	local DailyRewardInst = Player:WaitForChild("DailyRewardInst")
	local Due = DailyRewardInst:WaitForChild("Due")
	local Streak = DailyRewardInst:WaitForChild("Streak")
	local TimeValue = 0
	local Pause = false

	RewardService.SetValue:Connect(function(val)
		TimeValue = val
	end)

	local Gui = Player:WaitForChild("PlayerGui")
	local Main = Gui:WaitForChild("Main")
	local Hud = Main:WaitForChild("HUD")
	local Frame = Main.Frames:WaitForChild("Daily")
	local Toggle = Hud.Buttons:WaitForChild("Daily")
	local Alert = Toggle:WaitForChild("Alert")
	local StatusText = Frame:WaitForChild("Status")
	local RewardUI = {}

	for _, btn in pairs(Frame.Rewards:GetDescendants()) do
		if btn:IsA("GuiButton") then
			RewardUI[tostring(btn.Name)] = btn
			if not btn:FindFirstChildWhichIsA("UIScale") then
				local UIScale = Instance.new("UIScale")
				UIScale.Parent = btn
			end
			btn.MouseButton1Down:Connect(function()
				TweenService:Create(btn.UIScale, TweenInfo.new(0.1), { Scale = 0.965 }):Play()
			end)
			btn.MouseButton1Up:Connect(function()
				TweenService:Create(btn.UIScale, TweenInfo.new(0.1), { Scale = 1.05 }):Play()
			end)
			if getPlatform() == "Pc" then
				btn.MouseEnter:Connect(function()
					TweenService:Create(btn.UIScale, TweenInfo.new(0.1), { Scale = 1.05 }):Play()
				end)
				btn.MouseLeave:Connect(function()
					TweenService:Create(btn.UIScale, TweenInfo.new(0.1), { Scale = 1 }):Play()
				end)
			end
			btn.MouseButton1Click:Connect(function()
				if btn.CanClaim.Value then
					Pause = true
					Alert.Visible = false
					RewardService:GiveReward(btn.Name):andThen(function()
						SendNotification("Reward claimed!", Color3.fromRGB(0, 239, 0), 2, true)
					end)
				else
					local notifyText = tonumber(btn.Name) <= Streak.Value and "Already Claimed, come back tomorrow!"
						or "Claim this next time!"
					SendNotification(notifyText, Color3.fromRGB(255, 191, 0))
				end
				task.wait(0.1)
				Pause = false
			end)
		end
	end

	RunService.Stepped:Connect(function()
		for i, btn in pairs(RewardUI) do
			if Streak.Value == tonumber(i) then
				if Due.Value then
					EnableClaim(btn)
					for j, other in pairs(RewardUI) do
						if tonumber(j) < tonumber(i) then
							EnableClaimed(other)
						elseif tonumber(j) > tonumber(i) then
							LockReward(other)
						end
					end
				else
					EnableClaimed(btn)
				end
			end
		end
	end)

	Due:GetPropertyChangedSignal("Value"):Connect(function()
		Pause = Due.Value
		if Pause then
			RewardAvailableEffect(Alert, StatusText)
		end
	end)

	task.spawn(function()
		repeat
			task.wait(0.5)
		until TimeValue ~= 0
		while true do
			task.wait(1)
			if not Pause and TimeValue ~= 0 then
				TimeValue += 1
				if TimeValue >= (24 * 600) and TimeValue <= (24 * 600 * 2) then
					RewardService:SetClaim("d")
					TimeValue = 0
					Pause = true
				end
			end
		end
	end)

	RunService.Stepped:Connect(function()
		if not Pause and TimeValue ~= 0 and not Due.Value then
			local formatted = toHMS((24 * 3600) - TimeValue)
			StatusText.Text = formatted
			StatusText.TextColor3 = Color3.fromRGB(255, 170, 0)
		end
	end)

	if Due.Value then
		Pause = true
		task.delay(4, function()
			RewardAvailableEffect(Alert, StatusText)
			self.RewardToggle:Fire()
		end)
	end
end

return DailyRewardController
