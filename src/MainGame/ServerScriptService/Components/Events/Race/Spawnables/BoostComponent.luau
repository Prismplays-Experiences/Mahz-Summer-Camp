local Component = require("@Packages/Component")
local Knit = require("@Packages/Knit")
local RaceInfo = require("@Info/Events/Race")
local Physics = require("@Modules/Utils/Physics")

local IMPULSE = RaceInfo.playerStats.boostImpulse

export type BoostComponent = {
	Instance: BasePart & {
		["0"]: Attachment,
		["1"]: Attachment,
		Beam: Beam,
	},

	_fixBeam: (self: BoostComponent) -> (),
	_connectEvents: (self: BoostComponent) -> (),
	_getPlayerFromPart: (part: BasePart) -> Player?,
	_speedUpPlayer: (player: Player) -> (),
	_applyImpulseToPlayer: (player: Player) -> (),
}

local BoostComponent = Component.new({
	Tag = "Boost",
})

function BoostComponent.Construct(self: BoostComponent)
	self:_fixBeam()
	self:_connectEvents()
end

function BoostComponent._fixBeam(self: BoostComponent)
	self.Instance.Beam.Attachment0 = self.Instance["0"]
	self.Instance.Beam.Attachment1 = self.Instance["1"]
end

function BoostComponent._connectEvents(self: BoostComponent)
	self.Instance.Touched:Connect(function(otherPart)
		local player = self._getPlayerFromPart(otherPart)

		if not player then
			return
		end

		self._applyImpulseToPlayer(player)
		self._speedUpPlayer(player)
	end)
end

function BoostComponent._getPlayerFromPart(part: BasePart): Player?
	local character = part.Parent

	if character and character:IsA("Model") and character:FindFirstChild("Humanoid") then
		local player = game.Players:GetPlayerFromCharacter(character)
		return player
	end

	return nil
end

function BoostComponent._speedUpPlayer(player: Player)
	local raceSpeedService = Knit.GetService("RaceSpeedService")

	raceSpeedService:BoostPlayer(player)
end

function BoostComponent._applyImpulseToPlayer(player: Player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	Physics.ApplyImpulseRelativeToLookVector(IMPULSE, humanoidRootPart)
end

return BoostComponent
