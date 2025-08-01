local LapsProgress = require("./LapsProgress")
local CircleProgress = require("./CircleProgress")

export type ProgressTable = {
	total: number,
	circle: number,
	laps: number
}

export type ProgressCompiler = {
	IncrementLap: (self: ProgressCompiler, player: Player) -> (),

	GetEveryoneLaps: (self: ProgressCompiler) -> { [Player]: number },
	GetPlayerLaps: (self: ProgressCompiler, player: Player) -> number,

	GetProgresses: (self: ProgressCompiler) -> { [Player]: ProgressTable },
	GetProgressForPlayer: (self: ProgressCompiler, player: Player) -> ProgressTable,

	_lapsProgress: LapsProgress.LapsProgress,
}

export type ProgressTypes = "total" | "circle" | "laps"

local ProgressCompiler = {}
ProgressCompiler.__index = ProgressCompiler

function ProgressCompiler.new()
	local self = setmetatable({}, ProgressCompiler)

	self._lapsProgress = LapsProgress.new()

	return self
end

function ProgressCompiler.IncrementLap(self: ProgressCompiler, player: Player)
	self._lapsProgress:IncrementLap(player)
end

function ProgressCompiler.GetEveryoneLaps(self: ProgressCompiler): { [Player]: number }
	return self._lapsProgress:GetEveryoneLaps()
end

function ProgressCompiler.GetPlayerLaps(self: ProgressCompiler, player: Player): number
	return self._lapsProgress:GetPlayerLaps(player)
end

function ProgressCompiler.GetProgresses(self: ProgressCompiler): { [Player]: ProgressTable }
	local progresses = {}

	for player, _ in pairs(self._lapsProgress:GetEveryoneLaps()) do
		progresses[player] = self:GetProgressForPlayer(player)
	end

	return progresses
end

function ProgressCompiler.GetProgressForPlayer(self: ProgressCompiler, player: Player): ProgressTable
	local lapsProgress = self._lapsProgress:GetPlayerProgress(player)
	local maxLaps = self._lapsProgress.GetMaxLaps()
	local circleProgress = CircleProgress.Get(player)

	local progress = circleProgress / maxLaps + lapsProgress

	return {
		total = progress,
		circle = circleProgress,
		laps = lapsProgress
	}
end

return ProgressCompiler