local Knit = require("@Packages/Knit")
local RaceInfo = require("@Info/Events/Race")

local Landmark = require("./LandmarksService/Landmark")

local types = require("./types")

local LANDMARKS_FOLDER = RaceInfo.instances.track.landmarksFolder

type LandmarkSlot = types.LandmarkSlot
type LandmarksService = types.LandmarksService

local LandmarksService = Knit.CreateService({
	Name = "LandmarksService",
	Client = {
		LandmarkSpawned = Knit.CreateSignal("LandmarkSpawned"),
	},
})

function LandmarksService.KnitInit(self: LandmarksService)
	self.landmarks = {}

	for _, landmarkPart in ipairs(LANDMARKS_FOLDER:GetChildren()) do
		local landmark = Landmark.new(landmarkPart)

		self:AddLandmark(landmark)
	end
end

function LandmarksService.OccupyFreeSlots(self: LandmarksService, callback: (slotCframe: CFrame) -> Instance, numberOfSlots: number?)
	local allFreeSlots = self:GetFreeSlots()
	local slots = {}

	local iterationNumber = numberOfSlots or #allFreeSlots

	if iterationNumber == 0 then
		warn("LandmarksService: OccupyFreeSlots called with 0 slots, no slots will be iterated over")

		return slots
	end

	for _ = 1, iterationNumber do
		local randomIndex = math.random(1, #allFreeSlots)
		local slot = allFreeSlots[randomIndex]

		table.remove(allFreeSlots, randomIndex)
		table.insert(slots, slot)
		
		local instance = callback(slot.cframe)

		slot:Occupy(instance)
	end

	return slots
end

function LandmarksService.GetFreeSlots(self: LandmarksService)
	local allLandmarks = self:GetAllLandmarks()
	local freeSlots = {}

	for _, landmark in ipairs(allLandmarks) do
		for _, slot in ipairs(landmark:GetFreeSlots()) do
			if slot:IsFree() then
				table.insert(freeSlots, slot)
			end
		end
	end

	return freeSlots
end

function LandmarksService.AddLandmark(self: LandmarksService, landmark: types.Landmark)
	table.insert(self.landmarks, landmark)
end

function LandmarksService.SetLandmarks(self: LandmarksService, landmarks: { types.Landmark })
	self.landmarks = landmarks
end

function LandmarksService.GetLandmark(self: LandmarksService, landmarkIndex: number)
	local landmarks = self:GetAllLandmarks()

	return landmarks[landmarkIndex]
end

function LandmarksService.GetAllLandmarks(self: LandmarksService)
	return self.landmarks
end

return LandmarksService
