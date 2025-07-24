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

--> Setup
-----------------------------------------
local FoodChaos = Knit.CreateService({
	Name = "FoodChaos",
	Client = {
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

--> Utility Functions
-----------------------------------------

function RandomFood()
	local Food = KitchenFoods:GetChildren()[math.random(1, #KitchenFoods:GetChildren())]

	return
end

function DropFood(Count) end

--> Main Functions
-----------------------------------------
