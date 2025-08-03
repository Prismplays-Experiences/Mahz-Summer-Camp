local Component = require("@Packages/Component")
local Knit = require("@Packages/Knit")
local RaceInfo = require("@Info/Events/RaceInfo")
local Physics = require("@Modules/Utils/Physics")

local IMPULSE = RaceInfo.spikes.impulse
local RAGDOLL_DURATION = RaceInfo.spikes.ragdollDuration

export type SpikesComponent = {
	cooldowns: { [Player]: number },

	Instance: Model & {
		Spikes: MeshPart,
		Base: MeshPart,
	},

	_fixBeam: (self: SpikesComponent) -> (),
	_connectEvents: (self: SpikesComponent) -> (),
	_getPlayerFromPart: (part: BasePart) -> Player?,
	_ragdollPlayer: (player: Player) -> (),
	_applyImpulseToPlayer: (player: Player) -> (),
}

local SpikesComponent = Component.new({
	Tag = "Spikes",
})

function SpikesComponent.Construct(self: SpikesComponent)
	self:_connectEvents()
	self.cooldowns = {}
end

function SpikesComponent._connectEvents(self: SpikesComponent)
	self.Instance.Spikes.Touched:Connect(function(otherPart)
		local player = self._getPlayerFromPart(otherPart)

		if not player or time() - (self.cooldowns[player] or 0) < 4 then
			return
		end

		self.cooldowns[player] = time()

		self._applyImpulseToPlayer(player)
		self._ragdollPlayer(player)
	end)
end

function SpikesComponent._getPlayerFromPart(part: BasePart): Player?
	local character = part.Parent

	if character and character:IsA("Model") and character:FindFirstChild("Humanoid") then
		local player = game.Players:GetPlayerFromCharacter(character)
		return player
	end

	return nil
end

function SpikesComponent._ragdollPlayer(player: Player)
	local ragdollService = Knit.GetService("RagdollService")

	if ragdollService:IsRagdoll(player) then
		return
	end

	ragdollService:Ragdoll(player)

	task.wait(RAGDOLL_DURATION)

	ragdollService:Deragdoll(player)
end

function SpikesComponent._applyImpulseToPlayer(player: Player)
	local character = player.Character

	Physics:ApplyImpulseToPlayer(IMPULSE(character), player, false)
end

return SpikesComponent
