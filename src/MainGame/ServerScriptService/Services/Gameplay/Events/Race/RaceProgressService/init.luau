local Knit = require("@Packages/Knit")

local ProgressCompiler = require("./RaceProgressService/ProgressCompiler")
local RaceLeaderboard = require("./RaceProgressService/RaceLeaderboard")

local types = require("./types")

type ProgressTable = types.ProgressTable
type ProgressTypes = types.ProgressTypes
type RaceProgressService = types.RaceProgressService

local RaceProgressService = Knit.CreateService({
	Name = "RaceProgressService",
	Client = {},
})

function RaceProgressService.Start(self: RaceProgressService)
	self._progressCompiler = ProgressCompiler.new()
end

function RaceProgressService.Stop(self: RaceProgressService)
	self._progressCompiler = nil
end

function RaceProgressService.IncrementLap(self: RaceProgressService, player: Player)
	assert(self._progressCompiler, "ProgressCompiler is not initialized. Run :Start() before using this method")

	self._progressCompiler:IncrementLap(player)
end

function RaceProgressService.GetNearestPlayer(self: RaceProgressService, player: Player, progressKey: ProgressTypes?): Player?
	local progresses = self:GetProgresses()

	return RaceLeaderboard:GetNearestPlayer(progresses, player, progressKey)
end

function RaceProgressService.GetRelativePlayerInfo(self: RaceProgressService, player: Player, deltaIndex: number, progressKey: ProgressTypes?): {player: Player, progress: number}?
	local progresses = self:GetProgresses()

	return RaceLeaderboard:GetRelativePlayerInfo(progresses, player, deltaIndex, progressKey)
end

function RaceProgressService.GetLeaderboard(self: RaceProgressService, progressKey: ProgressTypes?): { [number]: {player: Player, progress: number} }
	local progresses = self:GetProgresses()

	return RaceLeaderboard.SortByLeaders(progresses, progressKey)
end

function RaceProgressService.GetProgresses(self: RaceProgressService): { [Player]: ProgressTable }
	assert(self._progressCompiler, "ProgressCompiler is not initialized. Run :Start() before using this method")

	return self._progressCompiler:GetProgresses()
end

function RaceProgressService.GetPlayerProgress(self: RaceProgressService, player: Player): ProgressTable
	assert(self._progressCompiler, "ProgressCompiler is not initialized. Run :Start() before using this method")

	return self._progressCompiler:GetProgressForPlayer(player)
end

function RaceProgressService.GetEveryoneLaps(self: RaceProgressService): { [Player]: number }
	assert(self._progressCompiler, "ProgressCompiler is not initialized. Run :Start() before using this method")

	return self._progressCompiler:GetEveryoneLaps()
end

function RaceProgressService.GetPlayerLaps(self: RaceProgressService, player: Player): number
	assert(self._progressCompiler, "ProgressCompiler is not initialized. Run :Start() before using this method")

	return self._progressCompiler:GetPlayerLaps(player)
end

return RaceProgressService