--> Services
----------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")
local HardNotification = require("@Modules/HardNotification")

--> Assets
----------------------------------------
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Confetti = Assets:WaitForChild("Confetti")
local Player = Players.LocalPlayer

local Models = ReplicatedStorage:WaitForChild("Models")
local SoundEffects = Models:WaitForChild("SoundEffects")

--> Variables
----------------------------------------

--> Knit Setup
----------------------------------------
local FoodController = Knit.CreateController({
	Name = "FoodController",
})

--> Utility Functions
----------------------------------------
function ShortNotification(Text, TextColor, Random)
	local NotificationTemplete = Confetti:WaitForChild("ShortNotification"):Clone()
	local randomx = math.random(25, 85) / 100
	local randomy = math.random(35, 85) / 100
	if Random then
		NotificationTemplete.Position = UDim2.fromScale(randomx, randomy)
	else
		NotificationTemplete.Position = UDim2.fromScale(0.5, 0.5)
	end

	local UIStroke = NotificationTemplete:WaitForChild("UIStroke")
	NotificationTemplete.Text = Text
	NotificationTemplete.TextColor3 = TextColor or Color3.fromRGB(255, 255, 255)
	NotificationTemplete.Visible = false
	NotificationTemplete.Parent = Player.PlayerGui:WaitForChild("Main"):WaitForChild("Core")
	local tweeninstroke = TweenService:Create(UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { Transparency = 0 })
	local tweenintext =
		TweenService:Create(NotificationTemplete, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { TextTransparency = 0 })
	local tweentextpos = TweenService:Create(
		NotificationTemplete,
		TweenInfo.new(1.6, Enum.EasingStyle.Quad),
		{ Position = UDim2.fromScale(randomx, randomy - 0.35) }
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

function RoundTo2DecimalPlaces(value)
	return math.floor(value * 100 + 0.5) / 100
end

--> Main Functions
----------------------------------------

function FoodController:KnitStart()
	self.KitchenService = Knit.GetService("KitchenService")

	self.KitchenService.FoodEaten:Connect(function(_, StrengthGain, isHighFood)
		StrengthGain = RoundTo2DecimalPlaces(StrengthGain)
		if StrengthGain < 0 then
			StrengthGain = math.abs(StrengthGain)
			SoundEffects.BadFood:Play()
			ShortNotification("-" .. StrengthGain .. " energy", Color3.fromRGB(255, 0, 0), true)
		elseif StrengthGain > 0 and not isHighFood then
			SoundEffects.EatSound:Play()
			ShortNotification("+" .. StrengthGain .. " energy", Color3.fromRGB(0, 255, 0), true)
		else
			SoundEffects.SuperFood:Play()
			ShortNotification("SUPER FOOD!", Color3.fromRGB(255, 235, 51), true)
			ShortNotification("+" .. StrengthGain .. " energy", Color3.fromRGB(0, 255, 0), true)
		end
	end)

	self.KitchenService.FoodReady:Connect(function()
		HardNotification.Send(
			Player,
			"Head to the kitchen! Food is ready!",
			"rbxassetid://112737726512337",
			SoundEffects.FoodReady,
			2.5
		)
	end)
end

return FoodController
