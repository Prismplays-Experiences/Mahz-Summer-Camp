-- NotificationsController

--> References
----------------------------------------
--[[

task.wait(3)
local data = {
	message = "Testing",
	color = Color3.fromRGB(255, 0, 0),
	duration = 1,
	reward = true/false,
	sound = the_sound_path, i.e SoundEffects.Play
	noDuplicates = true/false,
}
self:ShowNotification(data)
]]

--> Services
----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")
local confettiParticles = require("@Modules/Client/ConfettiParticles")

--> Variables
----------------------------------------
local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local MainUI = PlayerGui:WaitForChild("Main")
local ModuleAssets = MainUI:WaitForChild("ModuleAssets")
local ConfettiFrame = ModuleAssets:WaitForChild("ConfettiFrame")

local ConfettiAssets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Confetti")
local notificationTemplate = ConfettiAssets:WaitForChild("NotificationTemplate")

-- Colors defined by index
local Colors = {
	[1] = { Primary = Color3.fromRGB(255, 255, 255), Secondary = Color3.fromRGB(0, 53, 79) }, -- blue
	[2] = { Primary = Color3.fromRGB(255, 0, 0), Secondary = Color3.fromRGB(75, 0, 0) }, -- red
	[3] = { Primary = Color3.fromRGB(170, 0, 255), Secondary = Color3.fromRGB(49, 0, 74) }, -- purple
	[4] = { Primary = Color3.fromRGB(85, 255, 0), Secondary = Color3.fromRGB(21, 59, 0) }, -- green
	[5] = { Primary = Color3.fromRGB(255, 85, 0), Secondary = Color3.fromRGB(61, 20, 0) }, -- orange
	[6] = { Primary = Color3.fromRGB(230, 230, 0), Secondary = Color3.fromRGB(61, 20, 0) }, -- yellow
}

local confettiActive = false
local confettiColors = {
	Color3.fromRGB(255, 255, 100),
	Color3.fromRGB(255, 100, 100),
	Color3.fromRGB(100, 255, 100),
	Color3.fromRGB(100, 100, 255),
	Color3.fromRGB(255, 100, 255),
	Color3.fromRGB(100, 255, 255),
	Color3.fromRGB(255, 200, 100),
	Color3.fromRGB(200, 100, 255),
	Color3.fromRGB(255, 255, 255),
}

local AmountOfConfetti = 35
local confetti = {}

--> Confetti
----------------------------------------
confettiParticles.setGravity(Vector2.new(0, 1))
for _ = 1, AmountOfConfetti do
	local p = confettiParticles.createParticle(
		Vector2.new(0.5, 1),
		Vector2.new(math.random(90) - 45, math.random(70, 100)),
		ConfettiFrame,
		{ Color3.fromRGB(255, 255, 100), Color3.fromRGB(255, 100, 100) }
	)
	table.insert(confetti, p)
end

game:GetService("RunService").Heartbeat:Connect(function()
	for _, val in pairs(confetti) do
		if confettiColors then
			val:SetColors(confettiColors)
		end
		val.Enabled = confettiActive
		val:Update()
	end
end)

local fire = function(paramColors)
	confettiColors = paramColors
	task.spawn(function()
		confettiActive = true
		task.wait(0.01) -- task.wait(tick);
		confettiActive = false
	end)
end

local function spawnConfetti()
	-- Fire confetti
	-- print("here")
	fire({ Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255) })
end

--> Main Function: ShowNotification
----------------------------------------

local NotificationsController = Knit.CreateController({ Name = "UINotificationsController" })

-- data is expected as a table with fields:
-- message, color, duration, frameName, reward, sound, noDuplicates
function NotificationsController:ShowNotification(data)
	local message = data.message -- NotificationUtils.FormatMessage(data.message)
	local color = data.color
	local duration = data.duration or 1.9
	local frameName = data.frameName
	local reward = data.reward
	--local fromClient = data.fromClient
	local sound = data.sound
	local noDuplicates = data.noDuplicates

	local notifsFolder = ModuleAssets:WaitForChild("NotificationsFolder")
	local defaultHolder = notifsFolder:WaitForChild("NotificationHolder")

	task.spawn(function()
		if not message then
			return
		end

		-- Choose the correct frame to parent the notification
		local frame = defaultHolder

		if frameName then
			local candidate = notifsFolder:FindFirstChild(frameName)
			if candidate then
				frame = candidate
			end
		end

		if sound and sound:IsA("Sound") then
			sound:Play()
		end

		-- Check for duplicate notifications
		for _, child in ipairs(frame:GetChildren()) do
			if child:IsA("Frame") and child:FindFirstChild("TextLabel") then
				if
					child.Holder.TextLabel.Text == message
					and child.Holder.TextLabel.TextTransparency == 0
					and not noDuplicates
				then
					return
				end
			end
		end

		-- Clone the notification template and assign properties.

		local notification = notificationTemplate:Clone()
		local NotificationHolder = notification.Holder
		local textLabel = NotificationHolder:WaitForChild("TextLabel")
		textLabel.Text = message
		notification.UIScale.Scale = 0
		notification.Parent = frame

		-- Set text color either directly or via index in the Colors table
		if typeof(color) == "Color3" then
			textLabel.TextColor3 = color
		else
			local colorData = Colors[color] or Colors[1]
			textLabel.TextColor3 = colorData.Primary
		end

		notification.Visible = true

		-- Optionally trigger reward effect (confetti)
		if reward then
			spawnConfetti()
		end

		local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

		-- Define goal properties
		local rotateLeft = TweenService:Create(NotificationHolder, tweenInfo, { Rotation = -13 })
		local rotateRight = TweenService:Create(NotificationHolder, tweenInfo, { Rotation = 13 })
		local resetrotation = TweenService:Create(NotificationHolder, tweenInfo, { Rotation = 0 })
		local MoveUp =
			TweenService:Create(NotificationHolder, TweenInfo.new(0.5), { Position = UDim2.fromScale(0.5, 0) })

		-- Tween in the notification

		local scaleTween = TweenService:Create(
			notification.UIScale,
			TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
			{ Scale = 1 }
		)
		scaleTween:Play()

		MoveUp:Play()

		-- Loop the swing motion

		rotateLeft:Play()
		rotateLeft.Completed:Wait()

		rotateRight:Play()
		rotateRight.Completed:Wait()

		resetrotation:Play()

		task.wait(duration)

		-- Fade out
		local CloseTween =
			TweenService:Create(NotificationHolder, TweenInfo.new(0.5), { Position = UDim2.fromScale(-1.5, 0) })
		CloseTween:Play()
		CloseTween.Completed:Wait()

		notification:Destroy()
	end)
end

--> Initialization
----------------------------------------
function NotificationsController:KnitStart()
	-- Listening for remote requests
	local NotificationService = Knit.GetService("NotificationService")
	NotificationService.SendNotification:Connect(function(player, data)
		self:ShowNotification(player, data)
	end)
end

return NotificationsController
