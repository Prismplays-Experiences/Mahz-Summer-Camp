local ProgressCompiler = require("./ProgressCompiler")

type Leaderboard = {LeaderboardEntry}
type LeaderboardEntry = {
	player: Player,
	progress: number
}
type ProgressTable = ProgressCompiler.ProgressTable
type ProgressTypes = ProgressCompiler.ProgressTypes

export type RaceLeaderboard = {
	GetRelativePlayerInfo: (self: RaceLeaderboard, progresses: { [Player]: ProgressTable }, player: Player, deltaIndex: number, progressKey: ProgressTypes?) -> LeaderboardEntry?,

	SortByLeaders: (progresses: { [Player]: ProgressTable }, progressKey: ProgressTypes?) -> Leaderboard
}

local RaceLeaderboard = {}

function RaceLeaderboard.GetNearestPlayer(self: RaceLeaderboard, progresses: { [Player]: ProgressTable }, player: Player, progressKey: ProgressTypes?): Player?
	local nearestPlayer = nil

	local previousPlayerInfo = self:GetRelativePlayerInfo(progresses, player, -1, progressKey)
	local nextPlayerInfo = self:GetRelativePlayerInfo(progresses, player, 1, progressKey)

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


function RaceLeaderboard.GetRelativePlayerInfo(self: RaceLeaderboard, progresses: { [Player]: ProgressTable }, player: Player, deltaIndex: number, progressKey: ProgressTypes?): LeaderboardEntry?
	local leaderboard = self.SortByLeaders(progresses, progressKey)
	local playerInfo, playerIndex = nil, nil

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


function RaceLeaderboard.SortByLeaders(progresses: { [Player]: ProgressTable }, progressKey: ProgressTypes?): Leaderboard
	local leaderboard = {}

	progressKey = progressKey or "total"

	for player, progress in pairs(progresses) do
		table.insert(leaderboard, {
			player = player,
			progress = progress[progressKey]
		})
	end

	table.sort(leaderboard, function(a, b)
		return a.progress > b.progress
	end)

	return leaderboard
end

return RaceLeaderboard