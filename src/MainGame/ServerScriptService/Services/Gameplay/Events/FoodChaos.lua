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

local GeneralInfo = require("@Info/GeneralInfo")

--> Assets
-----------------------------------------
local Assets = ServerStorage:WaitForChild("Assets")
local Models = ReplicatedStorage:WaitForChild("Models")
local ModelAssets = require("@Assets")
local ImageAssets = ModelAssets.images
local SoundEffects = ReplicatedStorage:WaitForChild("Models"):WaitForChild("SoundEffects")
local SpeedBoostModel = Assets:WaitForChild("SpeedBoost")

local KitchenFoods = ReplicatedStorage:WaitForChild("Models")

local ScriptingProperties = workspace:WaitForChild("Game"):WaitForChild("ScriptingProperties")
local EventScriptingItems = ScriptingProperties:WaitForChild("Events")
local FoodChaosItems = EventScriptingItems:WaitForChild("FoodChaos")
local FoodsDropped = FoodChaosItems:WaitForChild("FoodDropped")
local SpawnPoints = FoodChaosItems:WaitForChild("SpawnPoints")

--> Setup
-----------------------------------------
local FoodChaos = Knit.CreateService({
	Name = "FoodChaosEvent",
	Client = {
		DropFood = Knit.CreateSignal(),
		EventSubStatus = Knit.CreateProperty(""),
		EventStatus = Knit.CreateProperty(""),
		WeightGained = Knit.CreateSignal(),
	},
})

--> Variables
-----------------------------------------
FoodChaos.ModeEnded = Signal.new()
FoodChaos.ExplodeTime = 60
FoodChaos.Trove = Trove.new()
FoodChaos.MaxWeightGained = 250
FoodChaos.MinPlayers = 2 -- 2
FoodChaos.LockWorkoutMachines = true
FoodChaos.YieldClock = true
FoodChaos.Ended = Signal.new()
FoodChaos.Details = {
	Text = "Food chaos!",
	Image = ImageAssets.FoodChaos,
}

local DropHeight = 260

--> Utility Functions
-----------------------------------------

--> Main Functions
-----------------------------------------

function FoodChaos:RandomFood()
	local Food = KitchenFoods:GetChildren()[math.random(1, #KitchenFoods:GetChildren())]:Clone()
	Food:SetAttribute("Weight", Food:GetAttribute("Weight") * self.ClockService.Days)
	self.Trove:Add(Food)
	return Food
end

function FoodChaos:DropFood(Count)
	for _ = 1, Count do
		local RandomFood = self:RandomFood()
		local SpawnPoint = SpawnPoints:GetChildren()[math.random(1, #SpawnPoints:GetChildren())]

		local size = SpawnPoint.Size
		local basePos = SpawnPoint.Position

		-- Generate a random point within the spawn part's X/Z bounds
		local randomX = math.random() * size.X - size.X / 2
		local randomZ = math.random() * size.Z - size.Z / 2

		local rayOrigin = Vector3.new(basePos.X + randomX, basePos.Y + DropHeight, basePos.Z + randomZ)

		local rayDirection = Vector3.new(0, -DropHeight, 0)

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.IgnoreWater = true

		local result = nil
		repeat
			workspace:Raycast(rayOrigin, rayDirection, raycastParams)
			task.wait()
		until result and result.Instance == SpawnPoint
		self.CLient.DropFood:FireAll(RandomFood, rayOrigin, result.Position)
	end
end

function FoodChaos:KnitStart()
	self.ClockService = Knit.GetService("ClockService")
end
