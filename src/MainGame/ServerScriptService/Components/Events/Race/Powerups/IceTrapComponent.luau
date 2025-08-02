local RaceInfo = require("@Info/Events/RaceInfo")
local Component = require("@Packages/Component")
local Knit = require("@Packages/Knit")

local FREEZE_DURATION = RaceInfo.powerups.iceBlock.duration

export type IceTrapComponent = {
	Instance: Model,
	_owner: Player,

	GetInstance: (self: IceTrapComponent) -> Model,
	
	_setProperties: (self: IceTrapComponent) -> (),
	_connectEvents: (self: IceTrapComponent) -> (),
	_getInstance: (self: IceTrapComponent) -> Model,
	_getOwner: (self: IceTrapComponent) -> Player,
}

local IceTrapComponent = Component.new({
	Tag = "IceTrap"
})

function IceTrapComponent:Construct()
	self:_connectEvents()
end

function IceTrapComponent._setProperties(self: IceTrapComponent)
	local instance = self:GetInstance()

	self._owner = instance:GetAttribute("Owner")
end

function IceTrapComponent:_connectEvents()
	local instance = self:GetInstance()
	local owner = self:_getOwner()

	instance.Touched:Connect(function(otherPart)
		local player = self._getPlayerFromPart(otherPart)

		if not player or player == owner then
			return
		end

		local freezeService = Knit.GetService("FreezeService")

		freezeService:Freeze(player)

		task.wait(FREEZE_DURATION)

		freezeService:Unfreeze(player)
	end)
end

function IceTrapComponent._getInstance(self: IceTrapComponent): Model
	return self.Instance
end

function IceTrapComponent._getOwner(self: IceTrapComponent): Player
	return self._owner
end

return IceTrapComponent