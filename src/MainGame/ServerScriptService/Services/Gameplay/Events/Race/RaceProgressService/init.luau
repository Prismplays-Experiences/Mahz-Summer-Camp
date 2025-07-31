local Knit = require("@Packages/Knit")

local ProgressCompiler = require("./RaceProgressService/ProgressCompiler")

type ProgressTable = ProgressCompiler.ProgressTable

export type RaceProgressService = {
	_progressCompiler: ProgressCompiler.ProgressCompiler?,

	IncrementLap: (self: RaceProgressService, player: Player) -> (),

	GetNearestPlayer: (self: RaceProgressService, player: Player) -> Player?,
	GetRelativePlayerInfo: (self: RaceProgressService, player: Player, deltaIndex: number, excludeLaps: boolean?) -> {player: Player, progress: number}?,

	GetLeaderboard: (self: RaceProgressService, excludeLaps: boolean?) -> { [number]: {player: Player, progress: number} },

	GetProgresses: (self: RaceProgressService) -> { [Player]: ProgressTable },
	GetPlayerProgress: (self: RaceProgressService, player: Player) -> ProgressTable,

	GetEveryoneLaps: (self: RaceProgressService) -> { [Player]: number },
	GetPlayerLaps: (self: RaceProgressService, player: Player) -> number
}

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

function RaceProgressService.GetNearestPlayer(self: RaceProgressService, player: Player): Player?
	local nearestPlayer = nil
	
	local previousPlayerInfo = self:GetRelativePlayerInfo(player, -1)
	local nextPlayerInfo = self:GetRelativePlayerInfo(player, 1)

	if previousPlayerInfo and nextPlayerInfo then
		if previousPlayerInfo.progress < nextPlayerInfo.progress then
			nearestPlayer = previousPlayerInfo.player
		else
			nearestPlayer = nextPlayerInfo.player
		end
	else
		nearestPlayer = if nextPlayerInfo then nextPlayerInfo.player elseif previousPlayerInfo then previousPlayerInfo.player else nil
	end

	return nearestPlayer
end

function RaceProgressService.GetRelativePlayerInfo(self: RaceProgressService, player: Player, deltaIndex: number, excludeLaps: boolean?): {player: Player, progress: number}?
	local leaderboard = self:GetLeaderboard(excludeLaps)
	local playerInfo = nil
	local playerIndex = nil

	for index, entry in ipairs(leaderboard) do
		if entry.player == player then
			playerIndex = index
			playerInfo = entry
			break
		end
	end

	if not playerIndex then
		return nil
	end

	local relativeIndex = playerIndex + deltaIndex

	if relativeIndex < 1 or relativeIndex > #leaderboard then
		return nil
	end

	local relativePlayerInfo = leaderboard[relativeIndex]

	relativePlayerInfo.progress = math.abs(relativePlayerInfo.progress - playerInfo.progress)

	return relativePlayerInfo
end

function RaceProgressService.GetLeaderboard(self: RaceProgressService, excludeLaps: boolean?): { [number]: {player: Player, progress: number} }
	local progresses = self:GetProgresses(excludeLaps)
	local leaderboard = {}

	for player, progress in pairs(progresses) do
		table.insert(leaderboard, {
			player = player,
			progress = progress
		})
	end

	table.sort(leaderboard, function(a, b)
		return a.progress > b.progress
	end)

	return leaderboard
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