local RaceInfo = require("@Info/Events/RaceInfo")
local Knit = require("@Packages/Knit")
local types = require("../types")

type CheckpointsService = types.CheckpointsService

local CHECKPOINTS = RaceInfo.trackConfig.checkpoints

local CheckpointsService = Knit.CreateService({
	Name = "CheckpointsService",
	Client = {},
})

function CheckpointsService.KnitInit(self: CheckpointsService)
	self._checkpoints = {}
end

function CheckpointsService.UpdateCheckpoints(self: CheckpointsService, progresses: { [Player]: number })
	local checkpoints = self:GetNextCheckpoints()
	local playersWhichCompletedLaps = {}

	for player, progress in pairs(progresses) do
		local currentGoalIndex = checkpoints[player] or 1
		local currentGoal = CHECKPOINTS[currentGoalIndex]

		if progress < currentGoal[2] and progress >= currentGoal[1] then
			checkpoints[player] = (currentGoalIndex % #CHECKPOINTS) + 1

			if currentGoalIndex == #CHECKPOINTS then
				table.insert(playersWhichCompletedLaps, player)
			end
		end
	end

	return playersWhichCompletedLaps
end

function CheckpointsService.GetNextCheckpoints(self: CheckpointsService)
	return self._checkpoints
end

return CheckpointsService
