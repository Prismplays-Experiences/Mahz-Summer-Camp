--> Services
----------------------------------------
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

--> Assets
----------------------------------------
local Player = game.Players:GetPlayerFromCharacter(script.Parent) :: Player
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

local MaxStrength = GeneralInfo.Strength
local FitThreshold = 100

local leaderstats = Player:WaitForChild("leaderstats")
local Strength = leaderstats:FindFirstChild("Strength") or Instance.new("IntValue")
Strength.Parent = leaderstats
Strength.Value = MaxStrength
Strength.Name = "Strength"
local CurrentDescription: "Fat" | "Fit" | nil = nil

--> Utility Functions
----------------------------------------
local humanoid = script.Parent:WaitForChild("Humanoid") :: Humanoid

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

function ChangeDescription(Type: "Fat" | "Fit")
	local userId = if Player.UserId > 0 then Player.UserId else 2205918664

	local HumanoidDescription = Players:GetHumanoidDescriptionFromUserId(userId)
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

function AdjustStrength(Strength, maxStrength, playerHumanoid)
	local scale = math.clamp(Strength / maxStrength, 0.01, 1)

	-- Interpolate scales based on Strength
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
function StrengthChanged()
	if Player.Character and Player.Character:FindFirstChild("Humanoid") then
		PlayerDetails.Strength.Text = `{Strength.Value}lbs`
		local playerHumanoid = Player.Character.Humanoid
		local Strength = Strength.Value

		if Strength > FitThreshold then
			ChangeDescription("Fat")
		else
			ChangeDescription("Fit")
		end

		AdjustStrength(Strength, MaxStrength, playerHumanoid)
	end
end
Strength:GetPropertyChangedSignal("Value"):Connect(StrengthChanged)
StrengthChanged()

script.Parent.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
PlayerDetails.PlayerName.Text = Player.DisplayName
PlayerDetails.Strength.Text = `{Strength.Value}lbs`
PlayerDetails.Adornee = Player.Character:WaitForChild("Head")
PlayerDetails.Parent = Player.Character
