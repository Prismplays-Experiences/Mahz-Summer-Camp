local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InfluencerStorage = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("InfluencerItems")
local InfluencerLogos = InfluencerStorage:WaitForChild("InfluencerLogos")
local DefaultPreset = InfluencerStorage:WaitForChild("DefaultPreset")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local DataHolder = require(Modules:WaitForChild("InfluencerData"))

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
function AddLogos(Player: Player)
	local dloaded = Player:WaitForChild("DataLoaded", 5)
	if dloaded == nil then
		return
	end
	if not CheckIfAlive(Player) then
		repeat
			task.wait()
		until Player.CharacterAdded
	end

	local character = Player.Character :: Model
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart

	local function CreateLogo(Image)
		local InfluencerLogoBillBoard
		if humanoidRootPart:FindFirstChild("InfluencerLogos") then
			InfluencerLogoBillBoard = humanoidRootPart.InfluencerLogos
		else
			local NewInfluencerLogos = InfluencerLogos:Clone()
			NewInfluencerLogos.Parent = humanoidRootPart
			InfluencerLogoBillBoard = NewInfluencerLogos
		end

		local NewDefaultPreset = DefaultPreset:Clone()
		NewDefaultPreset.Image = Image
		NewDefaultPreset.Parent = InfluencerLogoBillBoard
		--print(NewDefaultPreset.Parent)
	end

	local RankInGroup = Player:GetRankInGroup(DataHolder.GroupId)

	if RankInGroup >= 254 then
		CreateLogo(DataHolder.Icons.Dev)
	end
	if RankInGroup == 6 then
		CreateLogo(DataHolder.Icons.Admin)
	end
	if RankInGroup == 1 then
		CreateLogo(DataHolder.Icons.GroupMember)
	end

	for _, v in pairs(DataHolder.YoutubeCategory) do
		if v == Player.UserId then
			CreateLogo(DataHolder.Icons.Youtube)
		end
	end
	for _, v in pairs(DataHolder.TWCategory) do
		if v == Player.UserId then
			CreateLogo(DataHolder.Icons.TW)
		end
	end
	for _, v in pairs(DataHolder.TTCategory) do
		if v == Player.UserId then
			CreateLogo(DataHolder.Icons.TT)
		end
	end
	--for i,v in pairs(DataHolder.Admin) do

	--	if v == Player.UserId then

	--		CreateLogo(DataHolder.Icons.Admin)

	--	end

	--end
	for i, v in pairs(DataHolder.CustomPlayerIcons) do
		if i == Player.UserId then
			CreateLogo(v)
		end
	end

	repeat
		wait()
	until dloaded.Value == true

	if Player.MembershipType == Enum.MembershipType.Premium then
		CreateLogo(DataHolder.Icons.Premium)
	end

	Player:WaitForChild("GamepassFolder", 15)

	if (Player:WaitForChild("GamepassFolder"):WaitForChild("VIP") :: BoolValue).Value == true then
		CreateLogo("rbxassetid://15911620773")
	end
	Player:WaitForChild("GamepassFolder"):WaitForChild("VIP"):GetPropertyChangedSignal("Value"):Connect(function()
		if (Player:WaitForChild("GamepassFolder"):WaitForChild("VIP") :: BoolValue).Value == true then
			CreateLogo(DataHolder.Icons.VIP)
		end
	end)
end

function p_added(Player)
	local function CharAdded()
		repeat
			task.wait()
		until Player:WaitForChild("DataLoaded").Value
		repeat
			task.wait()
		until Player.Character
		AddLogos(Player)
	end
	if CheckIfAlive(Player) then
		CharAdded()
	end
	Player.CharacterAdded:Connect(CharAdded)
end

for _, v in pairs(game.Players:GetPlayers()) do
	p_added(v)
end

game.Players.PlayerAdded:Connect(p_added)
