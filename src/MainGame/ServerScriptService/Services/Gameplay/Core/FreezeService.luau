local RaceInfo = require("@Info/Events/RaceInfo")
local Knit = require("@Packages/Knit")
local Assets = require("@Assets")

local FREEZE_SOUND = Assets.sounds.Events.Race.Freeze
local ICE_BLOCK_TEMPLATE = RaceInfo.instances.other.bigIceBlockTemplate

local FreezeService = Knit.CreateService({
	Name = "FreezeService",
	Client = {},
})

function Weld(part, base)
	if part:IsA("BasePart") then
		local wc = Instance.new("WeldConstraint")
		wc.Part0 = base
		wc.Part1 = part
		wc.Parent = base
	else
		for _, child in pairs(part:GetChildren()) do
			Weld(child, base)
		end
	end
end

function FreezeService:Freeze(player: Player)
	local humanoid: Humanoid, humanoidRootPart: Part = self._getHumanoidAndRootPartFromPlayer(player)

	if not humanoid then
		return
	end

	humanoid.PlatformStand = true

	local soundPlayerService = Knit.GetService("SoundPlayerService")
	soundPlayerService:PlaySoundById(FREEZE_SOUND, player)

	local iceBlock = ICE_BLOCK_TEMPLATE:Clone()
	iceBlock.Parent = humanoidRootPart
	iceBlock.Name = "IceBlock"
	iceBlock:PivotTo(humanoidRootPart.CFrame)

	Weld(iceBlock, humanoidRootPart)
end

function FreezeService:Unfreeze(player: Player)
	local humanoid: Humanoid, humanoidRootPart: Part = self._getHumanoidAndRootPartFromPlayer(player)
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
