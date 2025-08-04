local Booker = require("@CustomModules/Booker")
local Knit = require("@Packages/Knit")
local RaceInfo = require("@Info/Events/RaceInfo")
local TableUtil = require("@Packages/TableUtil")

local types = require("./types")

type SlotSpawnerService<T> = types.SlotSpawnerService<T>

local SERVICES_INFO = {
	{
		name = "PowerupsSpawnerService",
		template = RaceInfo.instances.spawnables.powerupTemplate,
		count = RaceInfo.spawnCounts.powerups,
		offset = RaceInfo.slotsOffsets.powerup,
	},
	{
		name = "BoostsSpawnerService",
		template = RaceInfo.instances.spawnables.boostTemplate,
		count = RaceInfo.spawnCounts.boosts,
		offset = RaceInfo.slotsOffsets.boost,
	},
	{
		name = "SpikesSpawnerService",
		template = RaceInfo.instances.spawnables.spikesTemplate,
		count = RaceInfo.spawnCounts.spikes,
		offset = RaceInfo.slotsOffsets.spikes,
	},
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

	function Service.KnitInit<T>(self: SlotSpawnerService<T>)
		self:SetSlots({})
		self.landmarksService = Knit.GetService("LandmarksService")
		self.template = Booker.new(serviceInfo.template)

		self.template:Book(serviceInfo.count + 3)
	end

	function Service.Spawn<T>(self: SlotSpawnerService<T>, slotsCount: number?)
		task.spawn(function()
			local slots = self.landmarksService:OccupyFreeSlots(function(slotCframe: CFrame): Instance
				local spawnedInstance = self.template:Clone()
				local resultCframe = slotCframe * CFrame.new(serviceInfo.offset)

				spawnedInstance.Parent = RaceInfo.instances.spawnables.spawnedInstancesFolder

				setCframe(spawnedInstance, resultCframe)

				return spawnedInstance
			end, slotsCount or serviceInfo.count)

			self:SetSlots(slots)
		end)
	end

	function Service.Clean<T>(self: SlotSpawnerService<T>, slotsCount: number?)
		local allSlots = self:GetSlots()
		local count = slotsCount or #allSlots

		local slots = TableUtil.Sample(allSlots, count)

		for _, slot in pairs(slots) do
			slot:Clear(true)
		end

		local remainingSlots = TableUtil.Filter(allSlots, function(slot: types.LandmarkSlot)
			return not slot:IsFree()
		end)

		self:SetSlots(remainingSlots)
	end

	function Service.SetSlots<T>(self: SlotSpawnerService<T>, slots: { types.LandmarkSlot })
		self.slots = slots
	end

	function Service.GetSlots<T>(self: SlotSpawnerService<T>)
		return self.slots
	end
end

return {}
