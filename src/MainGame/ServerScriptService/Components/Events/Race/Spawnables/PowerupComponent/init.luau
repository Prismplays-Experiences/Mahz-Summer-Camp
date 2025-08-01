local Component = require("@Packages/Component")
local PowerupAnimator = require(script.PowerupAnimator)

export type PowerupComponent = {
	Instance: MeshPart,
	animator: PowerupAnimator.PowerupAnimator,

	Construct: (self: PowerupComponent) -> (),
}

local PowerupComponent = Component.new({
	Tag = "PowerupGiver",
})

function PowerupComponent.Construct(self: PowerupComponent)
	self.animator = PowerupAnimator.new(self.Instance)
end

function PowerupComponent.HeartbeatUpdate(self: PowerupComponent)
	self.animator:_animateFloating()
	self.animator:_animateRotation()
end

return PowerupComponent