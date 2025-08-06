--> Services
----------------------------------------
local ServerStorage = game:GetService("ServerStorage")

--> Assets
----------------------------------------
local Player = game.Players:GetPlayerFromCharacter(script.Parent)
local Assets = ServerStorage:WaitForChild("Assets")
local PlayerDetails = Assets:WaitForChild("PlayerDetails"):Clone(0)

local GeneralInfo = require("@Info/GeneralInfo")

--> Variables
----------------------------------------
local FatDescription = {
	LeftArm = 16144660809,
	RightArm = 16144657134,
	LeftLeg = 16144660806,
	RightLeg = 16144660823,
	Torso = 16144661484,
}

local FitDescription = {
	LeftArm = 32336182,
	RightArm = 32336117,
	LeftLeg = 32336243,
	RightLeg = 32336306,
	Torso = 32336059,
}

local MaxWeight = GeneralInfo.Weight
local FitThreshold = 100

local leaderstats = Player:WaitForChild("leaderstats")
local Weight = leaderstats:FindFirstChild("Weight") or Instance.new("IntValue")
Weight.Parent = leaderstats
Weight.Value = MaxWeight
Weight.Name = "Weight"
local CurrentDescription: "Fat" | "Fit" | nil = nil

--> Utility Functions
----------------------------------------
local humanoid = script.Parent:WaitForChild("Humanoid")

function DisableCollissions(Character)
	for _, part in pairs(Character:GetChildren()) do
		if part:IsA("MeshPart") and part.Name ~= "HumanoidRootPart" then
			part.CanCollide = false
			part.CollisionGroup = "PlayerCollission"
		end
	end
end

humanoid.StateChanged:Connect(function()
	DisableCollissions(Player.Character)
end)

local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
	if Player.Character and Player.Character:FindFirstChild("Humanoid") then
		DisableCollissions(Player.Character)
	end
end)

function ChangeDescription(Type)
	local HumanoidDescription = game.Players:GetHumanoidDescriptionFromUserId(Player.UserId)
	local Description
	if Type == "Fat" and CurrentDescription ~= "Fat" then
		CurrentDescription = "Fat"
		Description = FatDescription
	elseif Type == "Fit" and CurrentDescription :: string ~= "Fit" then
		CurrentDescription = "Fit"
		Description = FitDescription
	end
	if Description == nil then
		return
	end
	for i, v in Description do
		HumanoidDescription[i] = v
	end
	Player.Character.Humanoid:ApplyDescription(HumanoidDescription)

	task.wait(4)
	DisableCollissions(Player.Character)
end

function AdjustWeight(weight, maxWeight, playerHumanoid)
	local scale = math.clamp(weight / maxWeight, 0.01, 1)

	-- Interpolate scales based on weight
	local minWidth = 1
	local maxWidth = 2.5

	local minDepth = 1
	local maxDepth = 3

	if playerHumanoid:FindFirstChild("BodyWidthScale") then
		playerHumanoid.BodyWidthScale.Value = minWidth + (maxWidth - minWidth) * scale
	end

	if playerHumanoid:FindFirstChild("BodyDepthScale") then
		playerHumanoid.BodyDepthScale.Value = minDepth + (maxDepth - minDepth) * scale
	end
end

--> Main Functions
----------------------------------------
function WeightChanged()
	if Player.Character and Player.Character:FindFirstChild("Humanoid") then
		PlayerDetails.Weight.Text = `{Weight.Value}lbs`
		local playerHumanoid = Player.Character.Humanoid
		local weight = Weight.Value

		if weight > FitThreshold then
			ChangeDescription("Fat")
		else
			ChangeDescription("Fit")
		end

		AdjustWeight(weight, MaxWeight, playerHumanoid)
	end
end
Weight:GetPropertyChangedSignal("Value"):Connect(WeightChanged)
WeightChanged()

script.Parent.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
PlayerDetails.PlayerName.Text = Player.DisplayName
PlayerDetails.Weight.Text = `{Weight.Value}lbs`
PlayerDetails.Adornee = Player.Character:WaitForChild("Head")
PlayerDetails.Parent = Player.Character
