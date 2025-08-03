local Component = require("@Packages/Component")
local PowerupAnimator = require(script.PowerupAnimator)
local RandomPowerup = require(script.RandomPowerup)

type PowerupInstance = MeshPart

export type PowerupComponent = {
	Instance: PowerupInstance,
	animator: PowerupAnimator.PowerupAnimator,

	Construct: (self: PowerupComponent) -> (),

	_setProperties: (self: PowerupComponent) -> (),
	_connectEvents: (self: PowerupComponent) -> (),
	_getPlayerFromPart: (part: BasePart) -> Player?,

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

		instance:Destroy()
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

return PowerupComponent
