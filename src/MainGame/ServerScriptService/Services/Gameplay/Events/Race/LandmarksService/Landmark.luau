local TableUtils = require("@Packages/TableUtil")
local RaceInfo = require("@Info/Events/Race")

local LandmarkSlot = require("./LandmarkSlot")

local types = require("../types")

local PARALLEL_LINES_DISTANCE = RaceInfo.trackConfig.distanceBetweenParallelLines
local DIRECTION_MULTIPLIERS = { -1, 1 } -- Left and Right
local DISTANCE_MULTIPLIERS = { 0.5, 1.5 } -- Closer and further from the origin

type Landmark = types.Landmark
type LandmarkSlot = types.LandmarkSlot

local Landmark = {}
Landmark.__index = Landmark

function Landmark.new(landmarkPart: Part)
	local self = setmetatable({}, Landmark)

	self.origin = landmarkPart.CFrame
	self:_initSpawnSlots()

	return self
end

function Landmark._initSpawnSlots(self: Landmark)
	self.slots = {}

	for _, directionMultiplier in ipairs(DIRECTION_MULTIPLIERS) do
		for _, distanceMultiplier in ipairs(DISTANCE_MULTIPLIERS) do
			local resultMultiplier = directionMultiplier * distanceMultiplier * PARALLEL_LINES_DISTANCE
			local slotPosition = self.origin.Position + self.origin.RightVector * resultMultiplier
			local slotRotation = self.origin - self.origin.Position
			local slotCframe = slotRotation * CFrame.new(slotPosition)

			local slot = LandmarkSlot.new(slotCframe)

			table.insert(self.slots, slot)
		end
	end
end

function Landmark.GetFreeSlotsAmount(self: Landmark)
	local freeSlots = TableUtils.Filter(self.slots, function(slot: LandmarkSlot)
		return slot:IsFree()
	end)

	return #freeSlots
end

function Landmark.GetFreeSlotIndex(self: Landmark)
	for index, slot in ipairs(self.slots) do
		if slot:IsFree() then
			return index
		end
	end

	return nil
end

function Landmark.IsSlotFree(self: Landmark, slotIndex: number)
	local slot = self.slots[slotIndex]

	return slot and slot:IsFree() or false
end

function Landmark.OccupySlot(self: Landmark, slotIndex: number, instance: Instance)
	local slot = self.slots[slotIndex]

	if slot then
		slot:Occupy(instance)
	end
end

function Landmark.ClearAllSlots(self: Landmark, destroyInstances: boolean?)
	for index, _ in ipairs(self.slots) do
		self:ClearSlot(index, destroyInstances)
	end
end

function Landmark.ClearSlot(self: Landmark, slotIndex: number, destroyInstance: boolean?)
	destroyInstance = if destroyInstance == nil then true else destroyInstance

	local slot = self.slots[slotIndex]

	if slot then
		slot:Clear(destroyInstance)
	end
end

return Landmark
