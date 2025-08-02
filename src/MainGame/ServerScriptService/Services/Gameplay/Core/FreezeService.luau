local RaceInfo = require("@Info/Events/RaceInfo")

local ICE_BLOCK_TEMPLATE = RaceInfo.instances.other.bigIceBlockTemplate

local FreezeService = {}

function FreezeService:Freeze(player: Player)
	local humanoid: Humanoid, humanoidRootPart: Part = self:_getHumanoidAndRootPartFromPlayer(player)
	if not humanoid then
		return
	end

	local iceBlock = ICE_BLOCK_TEMPLATE:Clone()
	iceBlock.Parent = humanoidRootPart
	iceBlock.Name = "IceBlock"
	iceBlock:PivotTo(humanoidRootPart.CFrame)

	humanoid.PlatformStand = true
end

function FreezeService:Unfreeze(player: Player)
	local humanoid: Humanoid, humanoidRootPart: Part = self:_getHumanoidAndRootPartFromPlayer(player)
	if not humanoid then
		return
	end

	local iceBlock = humanoidRootPart:FindFirstChild("IceBlock")
	if iceBlock then
		iceBlock:Destroy()
	end

	humanoid.PlatformStand = false
end

function FreezeService._getHumanoidAndRootPartFromPlayer(player: Player): Humanoid?
	local character = player.Character
	if not character then
		return nil
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil
	end

	return humanoid, humanoidRootPart
end

return FreezeService