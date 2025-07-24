--> Services
----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")
local Trove = require("@Packages/Trove")

--. Assets
----------------------------------------
local ScriptingProperties = workspace:WaitForChild("Game"):WaitForChild("ScriptingProperties")
local EventScriptingItems = ScriptingProperties:WaitForChild("Events")
local FoodChaosItems = EventScriptingItems:WaitForChild("FoodChaos")
local FoodsDropped = FoodChaosItems:WaitForChild("FoodDropped")

local Models = ReplicatedStorage:WaitForChild("Models")
local KitchenFoods = Models:WaitForChild("KitchenFoods")

local Player = game.Players.LocalPlayer
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Confetti = Assets:WaitForChild("Confetti")

local Vfx = Assets:WaitForChild("Vfx")
local Puff = Vfx:WaitForChild("Puff")

local PlayerGui = Player.PlayerGui
local Main = PlayerGui:WaitForChild("Main")
local EventsInterfaces = Main:WaitForChild("EventsInterfaces")
-- local FoodBombFrame = EventsInterfaces:WaitForChild("FoodBomb")
-- local StatusTxt = FoodBombFrame:WaitForChild("Status")
-- local SubStatusTxt = FoodBombFrame:WaitForChild("SubStatus")

local Models = ReplicatedStorage:WaitForChild("Models")
local SoundEffects = Models:WaitForChild("SoundEffects")

--> Variables
----------------------------------------
local CircleSpawnOffset = Vector3.new(0, 10, 0)
local CircleTargetSize = Vector3.new(25, 1, 25)

--> Knit Setup
----------------------------------------
local FoodChaosController = Knit.CreateController({
	Name = "FoodChaosController",
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
	NotificationTemplete.Parent = Player.PlayerGui:WaitForChild("Main"):WaitForChild("EventsInterfaces")
	local tweeninstroke = TweenService:Create(UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { Transparency = 0 })
	local tweenintext =
		TweenService:Create(NotificationTemplete, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { TextTransparency = 0 })
	local tweentextpos = TweenService:Create(NotificationTemplete, TweenInfo.new(1.6, Enum.EasingStyle.Quad), {
		Position = UDim2.fromScale(NotificationTemplete.Position.X.Scale, NotificationTemplete.Position.Y.Scale - 0.35),
	})
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

--> Utility Functions
----------------------------------------

function MoveItem(Item, Position)
	if not Item then
		return
	end
	if Item and Item:IsA("BasePart") or Item:IsA("MeshPart") then
		Item.Position = Position
	elseif Item and Item:IsA("Model") then
		Item:MoveTo(Position)
	end
end

function AnchorItem(Item, Anchor)
	if not Item then
		return
	end
	if Item:IsA("BasePart") then
		Item.Anchored = Anchor
	end
	for _, Part in ipairs(Item:GetDescendants()) do
		if Part:IsA("BasePart") or Part:IsA("MeshPart") then
			Part.Anchored = Anchor
		end
	end
end

--> Main Functions
----------------------------------------

function FoodChaosController:FoodGainEffect(Food) end

function FoodChaosController:CircleSpawn(Food, Position, Weight)
	local CircularPart = self.Trove:Add(Instance.new("Part"))
	CircularPart.Size = Vector3.new(0.001, 0.001, 0.001)
	CircularPart.Position = Position - CircleSpawnOffset
	CircularPart.Anchored = true
	CircularPart.CanCollide = false
	local CircleGood = false
	if Weight > 0 then
		CircularPart.Color = Color3.fromRGB(0, 255, 0)
		CircleGood = true
	else
		CircularPart.Color = Color3.fromRGB(255, 0, 0)
	end
	local CircleTween = TweenService:Create(CircularPart, TweenInfo.new(1, Enum.EasingStyle.Bounce), {
		Size = CircleTargetSize,
	})

	local ShrinkTween = TweenService:Create(CircularPart, TweenInfo.new(1, Enum.EasingStyle.Bounce), {
		Size = Vector3.new(0.001, 0.001, 0.001),
	})

	CircleTween:Play()
	self.Trove:Connect(CircularPart.Touched, function(hit)
		local Humanoid = hit.Parent:FindFirstChild("Humanoid")
		local Obj
		if Humanoid then
			Obj = Humanoid.Parent
		else
			if KitchenFoods:FindFirstChild(hit.Name) then
				Obj = hit
			end
			if KitchenFoods:FindFirstChild(hit.Parent.Name) then
				Obj = hit.Parent
			end
		end
		if Obj:FindFirstChild("Humanoid") then
			if not CircleGood then
				ShortNotification("Bad Food Zone!", Color3.fromRGB(255, 0, 0), false)
				SoundEffects.Alarm:Play()
			end
		else
			local PlrCharacter = Player.Character
			local Mag = (PlrCharacter.HumanoidRootPart.Position - CircularPart.Position).Magnitude
			local NewPuff = Puff:Clone()
			NewPuff.Parent = CircularPart
			NewPuff:Emit(45)
			if Mag > CircularPart.Size.X / 2 then
				return
			end
			self:FoodGainEffect(Food)
		end
		ShrinkTween:Play()
	end)
end

function FoodChaosController:KnitStart()
	self.Trove = Trove.new()
	local FoodChaosService = Knit.GetService("FoodChaosEvent")
	FoodChaosService.DropFood:Connect(function(Food, Origin, TargetPosition)
		Food.Parent = FoodsDropped
		MoveItem(Food, Origin)
		AnchorItem(Food, false)
		self:CircleSpawn(Food, TargetPosition, Food:GetAttribute("Weight"))
	end)

	FoodChaosService.Ended:Connect(function()
		self.Trove:Cleanup()
	end)
end
