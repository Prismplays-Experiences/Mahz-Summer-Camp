local RaceInfo = require("@Info/Events/RaceInfo")
local types = require("./types")

local ICE_BLOCK_TEMPLATE = RaceInfo.instances.powerups.smallIceBlockTemplate

local RAYCAST_PARAMS = RaycastParams.new()
RAYCAST_PARAMS.FilterType = Enum.RaycastFilterType.Include
RAYCAST_PARAMS.FilterDescendantsInstances = {workspace.Game.Map.RandomParts}

type iceBlock = Model

type Powerup = types.Powerup & {
	_instance: iceBlock,
	_player: Player,

	_init: (self: Powerup, player: Player) -> (),
	_dropIceTrap: (self: Powerup) -> (),
	_getInstance: (self: Powerup) -> iceBlock,
	_getPlayer: (self: Powerup) -> Player,
	_getPlayerPosition: (self: Powerup) -> Vector3 | nil,
	_getRayResultPosition: (self: Powerup) -> Vector3 | nil,
	_calculatePositionOffset: (self: Powerup) -> Vector3,
	_setInstancePosition: (self: Powerup, position: Vector3) -> (),
}

local IceBlock = {}
IceBlock.__index = IceBlock

function IceBlock.Activate(player: Player)
	local self = IceBlock.new(player)

	self:_dropIceTrap()

	return true
end

function IceBlock.new(player: Player)
	local self = setmetatable({}, IceBlock)

	self._instance = ICE_BLOCK_TEMPLATE:Clone()
	self._instance.Parent = workspace.Game.Map.RandomParts

	self._player = player

	self._instance:SetAttribute("Owner", player.Name)

	return self
end

function IceBlock._dropIceTrap(self: Powerup)
	local rayResultPosition = self:_getRayResultPosition()

	if not rayResultPosition then
		return
	end

	local offsetPosition = self:_calculatePositionOffset()
	local position = rayResultPosition + offsetPosition

	self:_setInstancePosition(position)
end

function IceBlock._calculatePositionOffset(self: Powerup)
	local instance = self:_getInstance()

	local offset = instance:GetExtentsSize() / 2
	offset *= Vector3.new(0, 1, 0)

	return offset
end

function IceBlock._setInstancePosition(self: Powerup, position: Vector3)
	local instance = self:_getInstance()
	instance:PivotTo(CFrame.new(position))
end

function IceBlock._getRayResultPosition(self: Powerup)
	local humanoidPosition = self:_getPlayerPosition()
	local ray = workspace:Raycast(humanoidPosition, Vector3.new(0, -50, 0), RAYCAST_PARAMS)

	if not ray then
		return
	end

	local resultPosition = ray.Position
	return resultPosition
end

function IceBlock._getPlayerPosition(self: Powerup)
	local player = self:_getPlayer()
	local character = player.Character

	local humanoidRootPart = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if not humanoidRootPart then
		return
	end

	local humanoidPosition = humanoidRootPart.Position

	return humanoidPosition
end

function IceBlock._getInstance(self: Powerup): iceBlock
	return self._instance
end

function IceBlock._getPlayer(self: Powerup): Player
	return self._player
end


return IceBlock