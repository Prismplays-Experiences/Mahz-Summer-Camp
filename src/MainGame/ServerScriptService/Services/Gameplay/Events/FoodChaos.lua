--- there are bugs so dont use this event

--> Services
-----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")

--> Modules
-----------------------------------------
local Signal = require("@Packages/Signal")
local Knit = require("@Packages/Knit")
local Trove = require("@Packages/Trove")

-- local GeneralInfo = require("@Info/GeneralInfo")

--> Assets
-----------------------------------------
local Assets = ServerStorage:WaitForChild("Assets")
-- local Models = ReplicatedStorage:WaitForChild("Models")
-- local ModelAssets = require("@assets")
-- local ImageAssets = ModelAssets.images
-- local SoundEffects = ReplicatedStorage:WaitForChild("Models"):WaitForChild("SoundEffects")
local SpeedBoostModel = Assets:WaitForChild("SpeedBoost")

local KitchenFoods = ReplicatedStorage:WaitForChild("Models"):WaitForChild("KitchenFoods")

local ScriptingProperties = workspace:WaitForChild("Game"):WaitForChild("ScriptingProperties")
local EventScriptingItems = ScriptingProperties:WaitForChild("Events")
local FoodChaosItems = EventScriptingItems:WaitForChild("FoodChaos")
local FoodsDropped = FoodChaosItems:WaitForChild("FoodDropped")
local SpawnPoints = FoodChaosItems:WaitForChild("SpawnPoints")

local FoodBombItems = EventScriptingItems:WaitForChild("FoodBomb")
local ItemSpawnPoints = FoodBombItems:WaitForChild("ItemSpawnPoints")
local PowerupHolder = FoodBombItems:WaitForChild("PowerupHolder")

--> Setup
-----------------------------------------
local FoodChaos = Knit.CreateService({
	Name = "FoodChaos",
	Client = {
		DropFood = Knit.CreateSignal(),
		EventStatus = Knit.CreateProperty(""),
		ModeEnded = Knit.CreateSignal(),
	},
})

--> Variables
-----------------------------------------
FoodChaos.EventTime = 60
FoodChaos.Trove = Trove.new()
FoodChaos.MaxWeightGained = 250
FoodChaos.MinPlayers = 10 --- there are bugs so dont use this event
FoodChaos.LockWorkoutMachines = true
FoodChaos.YieldClock = true
FoodChaos.Ended = Signal.new()
FoodChaos.Details = {
	Text = "Food chaos!",
	Image = "rbxassetid://74060213881216",
}

local DropHeight = 260

local fireColorSequence = {
	ColorSequenceKeypoint.new(0, Color3.new(0, 0.333333, 1)),
	ColorSequenceKeypoint.new(1, Color3.new(0.341176, 0.768627, 1)),
}

--> Utility Functions
-----------------------------------------
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

function isInteger(num)
	return type(num) == "number" and num % 1 == 0
end

function CheckIfAlive(Plr)
	if not Plr.Character then
		return false
	end
	local char = Plr.Character
	if char then
		if char.Humanoid.Health <= 0 then
			return false
		end
	end
	return true
end

function CreateTrail(Character, Time)
	for _, v in pairs(Character:GetChildren()) do
		if v:IsA("BasePart") then
			local Att1 = Instance.new("Attachment")
			Att1.Parent = v
			Att1.Orientation = Vector3.new(-90, 0, 0)
			Att1.Position = Vector3.new(0, 0.5, 0)
			local Att2 = Instance.new("Attachment")
			Att2.Parent = v
			Att2.Orientation = Vector3.new(-90, 0, 0)
			Att2.Position = Vector3.new(0, -0.5, 0)
			local Trail = Instance.new("Trail")
			Trail.Parent = v
			Trail.Color = ColorSequence.new(fireColorSequence)
			Trail.Attachment0 = Att1
			Trail.Attachment1 = Att2
			Trail.Lifetime = 0.2
			Debris:AddItem(Att1, Time)
			Debris:AddItem(Att2, Time)
			Debris:AddItem(Trail, Time)
		end
	end
end

function SpeedPowerup(Powerup, spot)
	local TouchDebounce = false
	Powerup.Handle.Touched:Connect(function(hit)
		if TouchDebounce then
			return
		end
		TouchDebounce = true
		task.delay(2, function()
			TouchDebounce = false
		end)
		if not hit.Parent:FindFirstChild("Humanoid") then
			return
		end
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)

		local speedBoostTime = 6
		repeat
			task.wait()
		until CheckIfAlive(player)
		Powerup:Destroy()
		spot:RemoveTag("SpotTaken")
		local character = player.Character
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		humanoid.WalkSpeed = 30
		CreateTrail(character, speedBoostTime)
		task.wait(speedBoostTime)
		humanoid.WalkSpeed = 16
	end)
end

function ScaleObject(object, scaleFactor)
	if object:IsA("BasePart") then
		object.Size *= scaleFactor
	elseif object:IsA("Model") then
		local currentScale = object:GetScale()
		object:ScaleTo(currentScale * scaleFactor)
	end
end

--> Main Functions
-----------------------------------------

function FoodChaos:RandomFood()
	local Food = KitchenFoods:GetChildren()[math.random(1, #KitchenFoods:GetChildren())]:Clone()
	ScaleObject(Food, 2)
	Food:SetAttribute("Weight", Food:GetAttribute("Weight") * self.ClockService.Days)
	self.Trove:Add(Food)
	return Food
end

function FoodChaos:DropPowerups(Count, Powerup, func)
	local function getUntakenSpot()
		local items = ItemSpawnPoints:GetChildren()
		local availableSpots = {}

		for _, spot in ipairs(items) do
			if not spot:HasTag("SpotTaken") then
				table.insert(availableSpots, spot)
			end
		end

		if #availableSpots == 0 then
			return nil
		end

		local spot = availableSpots[math.random(1, #availableSpots)]
		spot:AddTag("SpotTaken")
		return spot
	end

	for _ = 1, Count do
		local spot = getUntakenSpot()
		if not spot then
			break
		end

		local Powerupclone = self.Trove:Add(Powerup:Clone())

		Powerupclone.Parent = PowerupHolder
		Powerupclone:MoveTo(spot.Position)
		task.spawn(func, Powerupclone, spot)
	end
end

function FoodChaos:DropFood(Count)
	for _ = 1, Count do
		local RandomFood = self:RandomFood()

		AnchorItem(RandomFood, true)
		RandomFood.Parent = FoodsDropped
		local SpawnPoint = SpawnPoints:GetChildren()[math.random(1, #SpawnPoints:GetChildren())]

		local size = SpawnPoint.Size
		local basePos = SpawnPoint.Position

		-- Generate a random point within the spawn part's X/Z bounds
		local randomX = math.random() * size.X - size.X / 2
		local randomZ = math.random() * size.Z - size.Z / 2

		local rayOrigin = Vector3.new(basePos.X + randomX, basePos.Y + DropHeight, basePos.Z + randomZ)
		MoveItem(RandomFood, rayOrigin)

		local rayDirection = Vector3.new(0, -(DropHeight + 1000), 0)

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { RandomFood }

		local result = nil
		repeat
			result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
			task.wait()
		until result and result.Instance == SpawnPoint
		-- RandomFood.Parent = FoodsDropped
		self.Client.DropFood:FireAll(RandomFood, rayOrigin, result.Position)
		task.delay(15, function()
			RandomFood:Destroy()
		end)
	end
end

function FoodChaos:Start()
	self.EventsService.Client.EnableEventsInterfaces:FireAll(true, "FoodChaos")
	local totalTime = self.EventTime
	self:DropPowerups(2, SpeedBoostModel, SpeedPowerup)
	for i = totalTime, 0, -1 do
		self.Client.EventStatus:Set(`{i}s`)
		local progress = (totalTime - i) / totalTime
		local wave = math.sin(progress * math.pi)
		local dropAmount = math.floor(3 + wave * 10)
		if isInteger(i / 15) and i < self.EventTime - 10 then
			self:DropPowerups(3, SpeedBoostModel, SpeedPowerup)
		end

		self:DropFood(50) -- dropAmount
		print("done 2")
		task.wait(1)
	end
	self.Client.EventStatus:Set("Food Chaos ended!")
	task.wait(3)
	self.Ended:Fire()
end

function FoodChaos:Clean()
	self.Client.ModeEnded:FireAll()
	self.EventsService.Client.EnableEventsInterfaces:FireAll(false)
	for _, v in ItemSpawnPoints:GetChildren() do
		v:RemoveTag("SpotTaken")
	end
	self.Trove:Clean()
end

function FoodChaos:KnitStart()
	self.ClockService = Knit.GetService("ClockService")
	self.EventsService = Knit.GetService("EventsService")
	self.WeightControl = Knit.GetService("WeightControl")
end

return FoodChaos
