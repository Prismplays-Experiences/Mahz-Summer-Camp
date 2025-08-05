--> Services
----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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
local HaloRing = Assets:WaitForChild("HaloRing")
local Confetti = Assets:WaitForChild("Confetti")

local Vfx = Assets:WaitForChild("VFX")
local Puff = Vfx:WaitForChild("Puff")

local PlayerGui = Player.PlayerGui
local Main = PlayerGui:WaitForChild("Main")
local EventsInterfaces = Main:WaitForChild("EventsInterfaces")
local FoodChaosFrame = EventsInterfaces:WaitForChild("FoodChaos")
local StatusTxt = FoodChaosFrame:WaitForChild("Status")
-- local SubStatusTxt = FoodBombFrame:WaitForChild("SubStatus")

local SoundEffects = Models:WaitForChild("SoundEffects")

--> Variables
----------------------------------------
-- local CircleSpawnOffset = Vector3.new(0, 6, 0)
local CircleTargetSize = Vector3.new(1, 18, 18)

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

--> Utility Functions
----------------------------------------

function CanCollideControl(Item, CanCollide)
	if not Item then
		return
	end
	if Item:IsA("BasePart") then
		Item.Anchored = CanCollide
	end
	for _, Part in ipairs(Item:GetDescendants()) do
		if Part:IsA("BasePart") or Part:IsA("MeshPart") then
			Part.Anchored = CanCollide
		end
	end
end

--> Main Functions
----------------------------------------

function FoodChaosController:FoodGainEffect(Food, Time, SizeFactor)
	if not Food then
		return
	end

	local parts = {}

	if Food:IsA("BasePart") then
		table.insert(parts, Food)
	end
	for _, descendant in ipairs(Food:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(parts, descendant)
		end
	end

	-- Store original sizes and transparency
	local originalSizes = {}
	local originalTransparencies = {}

	for _, part in ipairs(parts) do
		originalSizes[part] = part.Size
		originalTransparencies[part] = part.Transparency
	end

	local elapsed = 0

	local connection
	connection = RunService.RenderStepped:Connect(function(dt)
		elapsed += dt
		local alpha = math.clamp(elapsed / Time, 0, 1)

		for _, part in ipairs(parts) do
			if part and part.Parent then
				local newSize = originalSizes[part]:Lerp(originalSizes[part] * SizeFactor, alpha)
				part.Size = newSize

				local newTransparency = originalTransparencies[part] + (1 - originalTransparencies[part]) * alpha
				part.Transparency = math.clamp(newTransparency, 0, 1)
			end
		end

		if alpha >= 1 then
			connection:Disconnect()
		end
	end)
	if connection then
		self.Trove:Add(connection)
	end
end

function FoodChaosController:CircleSpawn(Food, Position, Weight)
	local CircularPart = self.Trove:Add(HaloRing:Clone())
	CircularPart.Position = Position -- - CircleSpawnOffset
	CircularPart.Size = Vector3.new(0.001, 0.001, 0.001)
	CircularPart.Anchored = true
	CircularPart.CanCollide = false
	CircularPart.Transparency = 0.6
	CircularPart.Parent = workspace

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
	local HumanoidDebounce = false
	self.Trove:Connect(CircularPart.Touched, function(hit)
		local Humanoid = hit.Parent:FindFirstChild("Humanoid")
		local Obj
		if Humanoid then
			Obj = Humanoid.Parent
		end
		if Obj == nil then
			return
		end
		if Obj:FindFirstChild("Humanoid") then
			if HumanoidDebounce then
				return
			end
			HumanoidDebounce = true

			if Weight < 0 then
				SoundEffects.BadFood:Play()
				self.WeightControlService:DecreaseWeight(Weight, true):andThen(function(status, weight)
					local AbsWeight = math.abs(weight)
					if status then
						ShortNotification(`gained {AbsWeight} fat`, Color3.fromRGB(255, 0, 0), false)
					end
				end)
			else
				SoundEffects.SuperFood:Play()
				self.WeightControlService:DecreaseWeight(Weight, true):andThen(function(status, weight)
					if status then
						local AbsWeight = math.abs(weight)
						ShortNotification(`lost {AbsWeight} fat`, Color3.fromRGB(0, 255, 0), false)
					end
				end)
			end
			task.delay(2, function()
				HumanoidDebounce = false
			end)
		end
		-- ShrinkTween:Play()
	end)
	return CircularPart, ShrinkTween
end

function FoodChaosController:KnitStart()
	self.Trove = Trove.new()
	local FoodChaosService = Knit.GetService("FoodChaos")
	self.WeightControlService = Knit.GetService("WeightControl")
	FoodChaosService.DropFood:Connect(function(Food, Origin, TargetPosition, duration)
		Food.Parent = FoodsDropped
		local CircularPart, ShrinkTween = self:CircleSpawn(Food, TargetPosition, Food:GetAttribute("Weight"))
		TargetPosition = CircularPart.Position
		local elapsedTime = 0
		local connection
		connection = RunService.RenderStepped:Connect(function(dt)
			elapsedTime += dt
			local alpha = math.clamp(elapsedTime / duration, 0, 1)

			local pos = Origin:Lerp(TargetPosition, alpha)
			local currentPivot = Food:GetPivot()
			local rotation = currentPivot - currentPivot.Position
			local newCFrame = CFrame.new(pos) * rotation
			Food:PivotTo(newCFrame)

			if alpha >= 1 then
				connection:Disconnect()
				connection = nil
			end
		end)
		repeat
			task.wait()
		until not connection or not Food:IsDescendantOf(workspace)
		-- local PlrCharacter = Player.Character
		local NewPuff = Puff:Clone()
		NewPuff.Parent = CircularPart
		NewPuff:Emit(75)
		self:FoodGainEffect(Food, 2, 6)
		task.delay(3, function()
			ShrinkTween:Play()
		end)

		-- local startTime = tick()

		-- local function IsWithinRange()
		-- 	if not Food or not Food:IsDescendantOf(workspace) then
		-- 		return false
		-- 	end
		-- 	local mag = (PlrCharacter.HumanoidRootPart.Position - TargetPosition).Magnitude
		-- 	return mag <= CircularPart.Size.Z / 1.5
		-- end

		-- repeat
		-- 	task.wait() -- check 10x per second
		-- until IsWithinRange() or tick() - startTime > 2

		-- if not IsWithinRange() then
		-- 	return
		-- end
	end)

	FoodChaosService.ModeEnded:Connect(function()
		self.Trove:Clean()
	end)

	FoodChaosService.EventStatus:Observe(function(txt)
		StatusTxt.Text = txt
	end)
end

return FoodChaosController
