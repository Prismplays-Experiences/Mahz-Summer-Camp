local RaceInfo = require("@Info/Events/RaceInfo")
local PowerupAnimator = {}
PowerupAnimator.__index = PowerupAnimator

local FLOATING_AMPLITUDE = RaceInfo.powerupGiver.floatingAmplitude
local FLOATING_SPEED = RaceInfo.powerupGiver.floatingSpeed
local ROTATION_SPEED = RaceInfo.powerupGiver.rotationSpeed

export type PowerupAnimator = {
	instance: MeshPart,

	_animateFloating: (self: PowerupAnimator) -> (),
	_animateRotation: (self: PowerupAnimator) -> (),
}

function PowerupAnimator.new(instance: MeshPart)
	local self = setmetatable({}, PowerupAnimator)

	self.instance = instance

	return self
end

function PowerupAnimator._animateFloating(self: PowerupAnimator)
	self.instance.Position += Vector3.new(0, math.sin(tick() * FLOATING_SPEED) * FLOATING_AMPLITUDE, 0)
end

function PowerupAnimator._animateRotation(self: PowerupAnimator)
	self.instance.Orientation += Vector3.new(0, ROTATION_SPEED, 0)
end

return PowerupAnimator