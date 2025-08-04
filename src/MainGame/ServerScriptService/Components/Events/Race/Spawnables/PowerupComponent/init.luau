local Component = require("@Packages/Component")
local PowerupAnimator = require(script.PowerupAnimator)
local RandomPowerup = require(script.RandomPowerup)
local Assets = require("@Assets")
local Knit = require("@Packages/Knit")

local POWERUP_SOUND = Assets.sounds.Events.Race.Powerup
type PowerupInstance = MeshPart

export type PowerupComponent = {
	Instance: PowerupInstance,
	animator: PowerupAnimator.PowerupAnimator,

	Construct: (self: PowerupComponent) -> (),

	_setProperties: (self: PowerupComponent) -> (),
	_connectEvents: (self: PowerupComponent) -> (),
	_getPlayerFromPart: (part: BasePart) -> Player?,
	_playSound: (player: Player) -> (),

	GetInstance: (self: PowerupComponent) -> PowerupInstance,
}

local PowerupComponent = Component.new({
	Tag = "PowerupGiver",
})

function PowerupComponent.Construct(self: PowerupComponent)
	self:_setProperties()
	self:_connectEvents()
end

function PowerupComponent.HeartbeatUpdate(self: PowerupComponent)
	self.animator:_animateFloating()
	self.animator:_animateRotation()
end

function PowerupComponent.GetInstance(self: PowerupComponent): PowerupInstance
	return self.Instance
end

function PowerupComponent._setProperties(self: PowerupComponent)
	self.animator = PowerupAnimator.new(self.Instance)
end

function PowerupComponent._connectEvents(self: PowerupComponent)
	local instance = self:GetInstance()

	instance.Touched:Connect(function(otherPart)
		local player = self._getPlayerFromPart(otherPart)

		if not player then
			return
		end

		local isReceived = RandomPowerup.Give(player)

		if not isReceived then
			return
		end

		instance.Position = Vector3.new(1000, 1000, 1000) -- Move the powerup out of sight
		self._playSound(player)
	end)
end

function PowerupComponent._getPlayerFromPart(part: BasePart): Player?
	local character = part.Parent

	if character and character:FindFirstChild("Humanoid") then
		local player = game.Players:GetPlayerFromCharacter(character)
		return player
	end

	return nil
end

function PowerupComponent._playSound(player: Player)
	local soundPlayerService = Knit.GetService("SoundPlayerService")
	soundPlayerService:PlaySoundById(POWERUP_SOUND, player)
end

return PowerupComponent
