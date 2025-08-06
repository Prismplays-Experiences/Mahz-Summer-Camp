--> Services
----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")
local Trove = require("@Packages/Trove")

local GeneralInfo = require("@Info/GeneralInfo")
local KitchenFoodInfo = require("@Info/KitchenFoods")

--> Assets
----------------------------------------
local Models = ReplicatedStorage:WaitForChild("Models")
local ScriptingProperties = workspace:WaitForChild("Game"):WaitForChild("ScriptingProperties")
local KitchenFoodSpawnPoints = ScriptingProperties:WaitForChild("KitchenFoodSpawnPoints")
local KitchenFoods = Models:WaitForChild("KitchenFoods")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local VFX = Assets:WaitForChild("Vfx")
local Highlights = Assets:WaitForChild("Highlights")

--> Variables
----------------------------------------
local SpawnTakenTag = "SpawnTaken"

--> Knit Setup
----------------------------------------
local KitchenService = Knit.CreateService({
	Name = "KitchenService",
	Client = {
		FoodEaten = Knit.CreateSignal("FoodEaten"),
		FoodReady = Knit.CreateSignal("FoodReady"),
	},
})

--> Utility Functions
----------------------------------------
function PickFoodSpawnPoint()
	local Item
	repeat
		task.wait()
		Item = KitchenFoodSpawnPoints:GetChildren()[math.random(1, #KitchenFoodSpawnPoints:GetChildren())]
	until not Item:HasTag(SpawnTakenTag)
	return Item
end
function ClearSpawnPointTags()
	for _, SpawnPoint in ipairs(KitchenFoodSpawnPoints:GetChildren()) do
		if SpawnPoint:HasTag(SpawnTakenTag) then
			SpawnPoint:RemoveTag(SpawnTakenTag)
		end
	end
end

function HighFoodEffect(Food)
	local newvfx = VFX:WaitForChild("Highfood"):Clone()
	local newhighlight = Highlights:WaitForChild("Highfood"):Clone()
	newhighlight.Parent = Food
	if Food:IsA("Model") then
		newvfx.Parent = Food.PrimaryPart
	else
		newvfx.Parent = Food
	end
end

function AnchorItem(Item)
	for _, part in ipairs(Item:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end
	if Item:IsA("BasePart") then
		Item.Anchored = true
	end
end

--> Main Functions
----------------------------------------

function KitchenService:ApplyFoodDetails(Food)
	local FoodInfo = KitchenFoodInfo.Foods[Food.Name]
	local WeightLoss, IsHighFood = self:CalculateFoodWeightLoss(Food)
	local ProximityPrompt = Instance.new("ProximityPrompt")
	self.FoodSpawnTrove:Add(ProximityPrompt)
	ProximityPrompt.ActionText = FoodInfo.Name
	ProximityPrompt.RequiresLineOfSight = false
	ProximityPrompt.MaxActivationDistance = 10

	if Food:IsA("Model") then
		ProximityPrompt.Parent = Food.PrimaryPart
	else
		ProximityPrompt.Parent = Food
	end

	if IsHighFood then
		HighFoodEffect(Food)
	end

	return ProximityPrompt, WeightLoss, IsHighFood
end

function KitchenService:CalculateFoodWeightLoss(Food)
	local FoodInfo = KitchenFoodInfo.Foods[Food.Name]
	if not FoodInfo then
		warn("Food info not found for: " .. Food.Name)
		return 0
	end

	local WeightLoss = FoodInfo.DefaultWeightLoss
	local MinInterval = KitchenFoodInfo.Info.FoodWeightLossIntervalMin
	local MaxInterval = KitchenFoodInfo.Info.FoodWeightLossIntervalMax
	local DayPercentage = self.ClockService.Days / GeneralInfo.MaxDays
	MaxInterval = math.round(DayPercentage * MaxInterval)
	local WeightLossInterval = math.random(MinInterval, MaxInterval) / KitchenFoodInfo.Info.WeightIntervalResolution

	WeightLoss = math.clamp(WeightLoss * WeightLossInterval, -math.huge, KitchenFoodInfo.Info.MaxWeightLoss)
	local HighFoodVal = KitchenFoodInfo.Info.HighFoodWeightLoss * (DayPercentage + 1.5)
	local IsHighFood = false
	if WeightLoss > HighFoodVal then
		IsHighFood = true
	end

	return WeightLoss, IsHighFood
end

function KitchenService:SpawnFoods(FoodCount)
	FoodCount = math.clamp(FoodCount, 1, #KitchenFoodSpawnPoints:GetChildren())
	for _ = 1, FoodCount do
		local SpawnPoint = PickFoodSpawnPoint()
		SpawnPoint:AddTag(SpawnTakenTag)

		local Food = KitchenFoods:GetChildren()[math.random(1, #KitchenFoods:GetChildren())]:Clone()
		if Food:IsA("Model") then
			Food:MoveTo(SpawnPoint.Position)
		else
			Food.Position = SpawnPoint.Position
		end

		local ProximityPrompt, WeightLoss, IsHighFood = self:ApplyFoodDetails(Food)
		self.FoodSpawnTrove:Connect(ProximityPrompt.Triggered, function(player)
			local Status = self.WeightControl:DecreaseWeight(player, WeightLoss, true)
			if Status then
				self.Client.FoodEaten:Fire(player, Food.Name, WeightLoss, IsHighFood)
			end
			Food:Destroy()
		end)
		local Highlight = Instance.new("Highlight")
		Highlight.Enabled = false
		Highlight.FillColor = Color3.fromRGB(255, 255, 255)
		Highlight.FillTransparency = 0.9
		Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		Highlight.Parent = Food
		self.FoodSpawnTrove:Connect(ProximityPrompt.PromptShown, function()
			Highlight.Enabled = true
		end)
		self.FoodSpawnTrove:Connect(ProximityPrompt.PromptHidden, function()
			Highlight.Enabled = false
		end)
		Food.Parent = SpawnPoint

		table.insert(self.ListOfFood, Food)

		if Food:IsA("Model") then
			Food:MoveTo(SpawnPoint.Position)
		else
			Food.Position = SpawnPoint.Position
		end
		task.spawn(function()
			task.wait(1)
			AnchorItem(Food)
		end)
	end
	self.Client.FoodReady:FireAll()
end

function KitchenService:Clear()
	self.FoodSpawnTrove:Clean()
	ClearSpawnPointTags()
	self:_clearListOfFood()
end

function KitchenService:KnitStart()
	self.ListOfFood = {}
	self.FoodSpawnTrove = Trove.new()
	self.ClockService = Knit.GetService("ClockService")
	self.WeightControl = Knit.GetService("WeightControl")
end

function KitchenService:_clearListOfFood()
	for _, food in ipairs(self.ListOfFood) do
		food:Destroy()
	end
end

return KitchenService
