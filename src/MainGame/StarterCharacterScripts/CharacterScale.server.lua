--> Services
----------------------------------------
local ServerStorage = game:GetService('ServerStorage')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--> Assets
----------------------------------------
local Player = game.Players:GetPlayerFromCharacter(script.Parent)
local Assets = ServerStorage:WaitForChild('Assets')
local PlayerDetails = Assets:WaitForChild('PlayerDetails'):Clone(0)

local GeneralInfo = require(ReplicatedStorage:WaitForChild('Info'):WaitForChild('GeneralInfo'))

--> Variables
----------------------------------------
local FatDescription = {
    LeftArm = 16144660809,
	RightArm = 16144657134,
	LeftLeg = 16144660806,
	RightLeg = 16144660823,
	Torso = 16144661484
}

local FitDescription = {
	LeftArm = 32336182,
	RightArm = 32336117,
	LeftLeg = 32336243,
	RightLeg = 32336306,
	Torso = 32336059
}

local MaxWeight = GeneralInfo.Weight
local FitThreshold = 100

local leaderstats = Player:WaitForChild('leaderstats')
local Weight = leaderstats:FindFirstChild('Weight') or Instance.new('IntValue',leaderstats)
Weight.Value = MaxWeight
Weight.Name = 'Weight'
local CurrentDescription = nil

--> Utility Functions
----------------------------------------
local humanoid = script.Parent:WaitForChild("Humanoid")

humanoid.StateChanged:Connect(function(oldState, newState)
        DisableCollissions(Player.Character)
end)



-- ():Connect(function(State)

-- end)
function DisableCollissions(Character)
    for _, part in pairs(Character:GetChildren()) do
        if part:IsA("MeshPart") and part.Name~= 'HumanoidRootPart' then
            part.CanCollide = false
        end
    end
end

local RunService = game:GetService('RunService')
RunService.Heartbeat:Connect(function()
    if Player.Character and Player.Character:FindFirstChild('Humanoid') then
        local humanoid = Player.Character.Humanoid
        DisableCollissions(Player.Character)
    end
end)

function ChangeDescription(Type)
    local HumanoidDescription = game.Players:GetHumanoidDescriptionFromUserId(Player.UserId)
    local Description
    if Type == 'Fat' and CurrentDescription ~= 'Fat' then
        CurrentDescription = 'Fat'
        Description = FatDescription
    elseif Type == 'Fit' and CurrentDescription ~= 'Fit' then
        CurrentDescription = 'Fit'
        Description = FitDescription
    end
    if Description == nil then return end
    for i,v in Description do
	    HumanoidDescription[i] = v
    end
    Player.Character.Humanoid:ApplyDescription(HumanoidDescription)

    task.wait(4)
    DisableCollissions(Player.Character)
end

function AdjustWeight(weight, maxWeight, humanoid)
    local scale = math.clamp(weight / maxWeight, 0.01, 1)

    -- Interpolate scales based on weight
    local minWidth = 1
    local maxWidth = 2.5

    local minDepth = 1
    local maxDepth = 3

    local minHeight = 1.3
    local maxHeight = 1 -- slightly shorter when fat

    if humanoid:FindFirstChild("BodyWidthScale") then
        humanoid.BodyWidthScale.Value = minWidth + (maxWidth - minWidth) * scale
    end

    if humanoid:FindFirstChild("BodyDepthScale") then
        humanoid.BodyDepthScale.Value = minDepth + (maxDepth - minDepth) * scale
    end

    -- if humanoid:FindFirstChild("BodyHeightScale") then
    --     humanoid.BodyHeightScale.Value = minHeight + (maxHeight - minHeight) * (1 - scale)
    -- end
end



--> Main Functions
----------------------------------------
function WeightChanged()
    if Player.Character and Player.Character:FindFirstChild('Humanoid') then
        PlayerDetails.Weight.Text = `{Weight.Value}lbs`
        local humanoid = Player.Character.Humanoid
        local weight = Weight.Value

        if weight > FitThreshold then
            ChangeDescription('Fat')
        else
            ChangeDescription('Fit')
        end

        AdjustWeight(weight, MaxWeight, humanoid)
    end
end
Weight:GetPropertyChangedSignal('Value'):Connect(WeightChanged)
WeightChanged()


script.Parent.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
PlayerDetails.PlayerName.Text = Player.DisplayName
PlayerDetails.Weight.Text = `{Weight.Value}lbs`
PlayerDetails.Adornee = Player.Character:WaitForChild('Head')
PlayerDetails.Parent = Player.Character