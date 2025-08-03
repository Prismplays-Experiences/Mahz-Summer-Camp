local RaceInfo = require("@Info/Events/RaceInfo")

local types = require("../types")

type LapsProgress = types.LapsProgress

local REQUIRED_LAPS = RaceInfo.trackConfig.laps

local LapsProgress = {}
LapsProgress.__index = LapsProgress

function LapsProgress.new()
	local self = setmetatable({}, LapsProgress)

	self._laps = {}

	return self
end

function LapsProgress.IncrementLap(self: LapsProgress, player: Player, quantity: number?)
	local laps = self:GetEveryoneLaps()

	if not laps[player] then
		laps[player] = 0
	end

	laps[player] = laps[player] + (quantity or 1)
end

function LapsProgress.GetPlayerProgress(self: LapsProgress, player: Player): number
	local laps = self:GetPlayerLaps(player)

	local progress = laps / REQUIRED_LAPS

	return progress
end

function LapsProgress.GetPlayerLaps(self: LapsProgress, player: Player): number
	local laps = self:GetEveryoneLaps()

	if not laps[player] then
		laps[player] = 0
	end

	return laps[player]
end

function LapsProgress.GetEveryoneLaps(self: LapsProgress): { [Player]: number }
	return self._laps
end

function LapsProgress.GetMaxLaps(): number
	return REQUIRED_LAPS
end

return LapsProgress
