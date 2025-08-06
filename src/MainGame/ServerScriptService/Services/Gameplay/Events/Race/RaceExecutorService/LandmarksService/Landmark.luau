local TableUtils = require("@Packages/TableUtil")
local RaceInfo = require("@Info/Events/RaceInfo")

local LandmarkSlot = require("./LandmarkSlot")

local types = require("../types")

local PARALLEL_LINES_DISTANCE = RaceInfo.trackConfig.distanceBetweenParallelLines
local DIRECTION_MULTIPLIERS = { -1, 1 } -- Left and Right
local DISTANCE_MULTIPLIERS = { 0.5, 0.5 + 1, 0.5 + 1 * 2, 0.5 + 1 * 3 } -- Closer and further from the origin

local VISUALIZE = false

type Landmark = types.Landmark
type LandmarkSlot = types.LandmarkSlot

local Landmark = {}
Landmark.__index = Landmark

function Landmark.new(landmarkPart: Part)
	local self = setmetatable({}, Landmark)

	self.origin = landmarkPart.CFrame
	self:_initSpawnSlots(landmarkPart:FindFirstChild("SurfaceGui"))

	if not VISUALIZE then
		landmarkPart.Transparency = 1

		if landmarkPart:FindFirstChild("SurfaceGui") then
			(landmarkPart:FindFirstChild("SurfaceGui") :: Instance):Destroy()
		end
	end

	return self
end

function Landmark._initSpawnSlots(self: Landmark, decal: SurfaceGui)
	self.slots = {}

	for _, directionMultiplier in ipairs(DIRECTION_MULTIPLIERS) do
		for _, distanceMultiplier in ipairs(DISTANCE_MULTIPLIERS) do
			local resultMultiplier = directionMultiplier * distanceMultiplier * PARALLEL_LINES_DISTANCE
			local slotCframe = self.origin + self.origin.RightVector * resultMultiplier

			local slot = LandmarkSlot.new(slotCframe)

			table.insert(self.slots, slot)

			if not VISUALIZE then
				continue
			end

			local visualizedSlot = Instance.new("Part")
			visualizedSlot.Size = Vector3.one * 2
			visualizedSlot.CFrame = slotCframe
			visualizedSlot.Anchored = true
			visualizedSlot.Transparency = 0.5
			visualizedSlot.Parent = workspace

			local newDecal = decal:Clone()
			newDecal.Parent = visualizedSlot
		end
	end
end

function Landmark.GetFreeSlots(self: Landmark)
	local freeSlots = TableUtils.Filter(self.slots, function(slot: LandmarkSlot)
		return slot:IsFree()
	end)

	return freeSlots
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
