local Knit = require("@Packages/Knit")
local RaceInfo = require("@Info/Events/Race")
local TableUtil = require("@Packages/TableUtil")

local types = require("./types")

type SlotSpawnerService = types.SlotSpawnerService

local SERVICES_INFO = {
	{
		name = "PowerupsService",
		template = RaceInfo.instances.track.powerup,
		count = RaceInfo.powerups.count,
		offset = RaceInfo.slotsOffsets.powerup,
	},
	{
		name = "BoostsService",
		template = RaceInfo.instances.obstacles.boostTemplate,
		count = RaceInfo.boosts.count,
		offset = RaceInfo.slotsOffsets.boost,
	},
	{
		name = "SpikesService",
		template = RaceInfo.instances.obstacles.spikesTemplate,
		count = RaceInfo.spikes.count,
		offset = RaceInfo.slotsOffsets.spikes,
	}
}

local function setCframe(instance: Instance, cframe: CFrame)
	if instance:IsA("BasePart") then
		instance.CFrame = cframe
	elseif instance:IsA("Model") then
		instance:PivotTo(cframe)
	end
end

for _, serviceInfo in pairs(SERVICES_INFO) do
	local Service = Knit.CreateService({
		Name = serviceInfo.name,
		Client = {},
	})

	function Service.KnitInit(self: SlotSpawnerService)
		self:SetSlots({})
		self.landmarksService = Knit.GetService("LandmarksService")
	end

	function Service.Spawn(self: SlotSpawnerService, slotsCount: number?)
		local slots = self.landmarksService:OccupyFreeSlots(function(slotCframe: CFrame): Instance
			local spawnedInstance = serviceInfo.template:Clone()
			local resultCframe = slotCframe * CFrame.new(serviceInfo.offset)

			setCframe(spawnedInstance, resultCframe)

			return spawnedInstance
		end, slotsCount or serviceInfo.count)

		self:SetSlots(slots)
	end

	function Service.Clean(self: SlotSpawnerService, slotsCount: number?)
		local allSlots = self:GetSlots()
		local count = slotsCount or #allSlots

		local slots = TableUtil.Sample(allSlots, count)

		for _, slot in pairs(slots) do
			slot:Clear()
		end

		local remainingSlots = TableUtil.Filter(allSlots, function(slot: types.LandmarkSlot)
			return not slot:IsFree()
		end)

		self:SetSlots(remainingSlots)
	end

	function Service.SetSlots(self: SlotSpawnerService, slots: { types.LandmarkSlot })
		self.slots = slots
	end

	function Service.GetSlots(self: SlotSpawnerService)
		return self.slots
	end
end

return nil