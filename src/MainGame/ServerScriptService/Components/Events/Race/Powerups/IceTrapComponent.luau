local RaceInfo = require("@Info/Events/RaceInfo")
local Component = require("@Packages/Component")
local Knit = require("@Packages/Knit")

local FREEZE_DURATION = RaceInfo.powerups.iceBlock.duration

export type IceTrapInstance = Model & {
	Meshessd_Cube: MeshPart,
}

export type IceTrapComponent = {
	Instance: IceTrapInstance,
	_owner: Player,

	_setProperties: (self: IceTrapComponent) -> (),
	_connectEvents: (self: IceTrapComponent) -> (),
	_getInstance: (self: IceTrapComponent) -> IceTrapInstance,
	_getOwner: (self: IceTrapComponent) -> Player,
}

local IceTrapComponent = Component.new({
	Tag = "IceTrap",
})

function IceTrapComponent:Construct()
	self:_setProperties()
	self:_connectEvents()
end

function IceTrapComponent._setProperties(self: IceTrapComponent)
	local instance = self:_getInstance()

	self._owner = instance:GetAttribute("Owner")
end

function IceTrapComponent:_connectEvents()
	local instance = self:_getInstance()
	local owner = self:_getOwner()

	instance.Meshessd_Cube.Touched:Connect(function(otherPart)
		local player = self._getPlayerFromPart(otherPart)

		if not player or player == owner then
			return
		end

		local freezeService = Knit.GetService("FreezeService")

		task.spawn(function()
			freezeService:Freeze(player)

			task.wait(FREEZE_DURATION)

			freezeService:Unfreeze(player)
		end)

		instance:Destroy()
	end)
end

function IceTrapComponent._getInstance(self: IceTrapComponent): Model
	return self.Instance
end

function IceTrapComponent._getOwner(self: IceTrapComponent): Player
	return self._owner
end

function IceTrapComponent._getPlayerFromPart(part: BasePart): Player?
	local character = part.Parent

	if character and character:FindFirstChild("Humanoid") then
		local player = game.Players:GetPlayerFromCharacter(character)
		return player
	end

	return nil
end

return IceTrapComponent
