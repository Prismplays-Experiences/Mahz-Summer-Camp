local Knit = require("@Packages/Knit")
local RaceInfo = require("@Info/Events/Race")

local Landmark = require("./LandmarksService/Landmark")

local types = require("./types")

local LANDMARKS_FOLDER = RaceInfo.instances.track.landmarksFolder

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

		table.insert(self.landmarks, landmark)
	end
end

function LandmarksService.IterateOverLandmarks(callback: (landmarkCframe: CFrame) -> (), numberOfLandmarks: number?)
	local landmarksFolderChildren = LANDMARKS_FOLDER:GetChildren()
	local landmarks = {}

	for _ = 1, numberOfLandmarks or #LANDMARKS_FOLDER:GetChildren() do
		local randomIndex = math.random(1, #landmarksFolderChildren)
		local landmark = landmarksFolderChildren[randomIndex]

		table.insert(landmarks, landmark)
		table.remove(landmarksFolderChildren, randomIndex)
	end

	for _, landmark in ipairs(landmarks) do
		callback(landmark.CFrame)
	end
end

return LandmarksService
