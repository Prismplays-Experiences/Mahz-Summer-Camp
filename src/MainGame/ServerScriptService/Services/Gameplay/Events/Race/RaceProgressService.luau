local Players = game:GetService("Players")

local RaceInfo = require("@Info/Events/Race")
local Mathematics = require("@Modules/Utils/Mathematics")
local Knit = require("@Packages/Knit")

local POLAR_PERPENDICULAR_AXIS_INSTANCE = RaceInfo.instances.track.polarPerpendicularAxis
local MAX_ANGLE = 2 * math.pi
local REQUIRED_LAPS = RaceInfo.trackConfig.laps

export type RaceProgressService = {
	_laps: { [Player]: number },

	GetNearestPlayer: (self: RaceProgressService, player: Player) -> Player?,
	GetRelativePlayerInfo: (self: RaceProgressService, player: Player, deltaIndex: number, excludeLaps: boolean?) -> {player: Player, progress: number}?,

	GetLeaderboard: (self: RaceProgressService, excludeLaps: boolean?) -> { [number]: {player: Player, progress: number} },

	GetProgresses: (self: RaceProgressService, excludeLaps: boolean?) -> { [Player]: number },
	GetProgressForPlayer: (self: RaceProgressService, player: Player, excludeLaps: boolean?) -> number,

	GetLaps: (self: RaceProgressService) -> { [Player]: number },
	GetLapsForPlayer: (self: RaceProgressService, player: Player) -> number
}

local RaceProgressService = Knit.CreateService({
	Name = "RaceProgressService",
	Client = {},
})

function RaceProgressService.KnitInit(self: RaceProgressService)
	self._laps = {}
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

function RaceProgressService.GetProgresses(self: RaceProgressService, excludeLaps: boolean?): { [Player]: number }
	local progresses = {}

	for _, player in Players:GetPlayers() do
		progresses[player] = self:GetProgressForPlayer(player, excludeLaps)
	end

	return progresses
end

function RaceProgressService.GetProgressForPlayer(self: RaceProgressService, player: Player, excludeLaps: boolean?): number
	local angle = Mathematics.CalculateAngleBetweenPlayerAndPart(player, POLAR_PERPENDICULAR_AXIS_INSTANCE)
	local progress = angle / MAX_ANGLE

	if excludeLaps == false or excludeLaps == nil then
		local laps = self:GetLapsForPlayer(player)
		progress = (progress + laps) / REQUIRED_LAPS
	end

	return progress
end

function RaceProgressService.GetLapsForPlayer(self: RaceProgressService, player: Player): number
	local laps = self:GetLaps()

	return laps[player]
end

function RaceProgressService.GetLaps(self: RaceProgressService): { [Player]: number }
	return self._laps
end

return RaceProgressService