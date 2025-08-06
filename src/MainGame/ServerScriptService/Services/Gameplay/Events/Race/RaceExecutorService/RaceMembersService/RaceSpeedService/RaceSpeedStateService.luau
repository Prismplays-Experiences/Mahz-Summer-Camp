local RaceInfo = require("@Info/Events/RaceInfo")
local Knit = require("@Packages/Knit")
local Arch = require("@Packages/Arch")
local types = require("../../types")

local DEFAULT_SPEED = RaceInfo.playerStats.defaultSpeed
local BOOSTED_SPEED = RaceInfo.playerStats.boostedSpeed
local BOOST_DURATION = RaceInfo.playerStats.boostDuration

type RaceSpeedStateService = types.RaceSpeedStateService

local RaceSpeedStateService = Knit.CreateService({
	Name = "RaceSpeedStateService",
	Client = {},
})

function RaceSpeedStateService.KnitInit(self: RaceSpeedStateService)
	self._playersStates = {}
	self._playersSpeed = {}
end

function RaceSpeedStateService.BoostPlayer(self: RaceSpeedStateService, player: Player)
	local stateMachine = self:_getPlayerStateMachine(player)

	if not stateMachine then
		self:CreateStateMachineForPlayer(player)
		stateMachine = self:_getPlayerStateMachine(player)
	end

	if stateMachine then
		if not stateMachine._running then
			stateMachine:Start()
		end

		if stateMachine.datamodel.current.id == "boosted" then
			return
		end

		stateMachine:Send("startBoost")

		task.wait(BOOST_DURATION)

		stateMachine:Send("stopBoost")
	end
end

function RaceSpeedStateService.StartStateMachines(self: RaceSpeedStateService)
	for _, stateMachine in pairs(self:_getAllPlayersStateMachines()) do
		stateMachine:Start()
	end
end

function RaceSpeedStateService.StopStateMachines(self: RaceSpeedStateService)
	for player, stateMachine in pairs(self:_getAllPlayersStateMachines()) do
		stateMachine:Stop()

		self:_setPlayerSpeed(player, 16)
	end
end

function RaceSpeedStateService.CreateStateMachineForPlayer(self: RaceSpeedStateService, player: Player)
	local states = self:_getAllPlayersStateMachines()
	local stateMachine = Arch.createMachine({
		id = "race_speed_machine_" .. player.Name,
		initial = "default",

		states = {
			default = {
				OnEntry = function()
					self:_enterDefaultMode(player)
				end,
				events = {
					startBoost = "boosted",
				},
			},
			boosted = {
				OnEntry = function()
					self:_enterBoostMode(player)
				end,
				events = {
					stopBoost = { target = "default" },
				},
			},
		},
	})

	states[player] = stateMachine
end

function RaceSpeedStateService.GetSpeed(self: RaceSpeedStateService, player: Player): number
	return self._playersSpeed[player]
end

function RaceSpeedStateService._getPlayerStateMachine(self: RaceSpeedStateService, player: Player): { [any]: any }?
	local states = self:_getAllPlayersStateMachines()

	return states[player]
end

function RaceSpeedStateService._getAllPlayersStateMachines(self: RaceSpeedStateService): { [Player]: { [any]: any } }
	return self._playersStates
end

function RaceSpeedStateService._enterBoostMode(self: RaceSpeedStateService, player: Player)
	self:_setPlayerSpeed(player, BOOSTED_SPEED)
end

function RaceSpeedStateService._enterDefaultMode(self: RaceSpeedStateService, player: Player)
	self:_setPlayerSpeed(player, DEFAULT_SPEED)
end

function RaceSpeedStateService._setPlayerSpeed(self: RaceSpeedStateService, player: Player, speed: number)
	local playersSpeed = self:_getPlayersSpeed()

	playersSpeed[player] = speed
end

function RaceSpeedStateService._getPlayersSpeed(self: RaceSpeedStateService): { [Player]: number }
	return self._playersSpeed
end

return RaceSpeedStateService
