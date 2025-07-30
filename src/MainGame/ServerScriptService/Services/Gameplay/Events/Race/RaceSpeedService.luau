local RaceInfo = require("@Info/Events/Race")
local Knit = require("@Packages/Knit")
local Arch = require("@Packages/Arch")

local DEFAULT_SPEED = RaceInfo.playerStats.defaultSpeed
local BOOSTED_SPEED = RaceInfo.playerStats.boostedSpeed
local BOOST_DURATION = RaceInfo.playerStats.boostDuration

export type RaceSpeedService = {
	CreateStateMachineForPlayer: (self: RaceSpeedService, player: Player) -> (),

	BoostPlayer: (self: RaceSpeedService, player: Player) -> (),

	StartStateMachines: (self: RaceSpeedService) -> (),
	StopStateMachines: (self: RaceSpeedService) -> (),

	_getPlayerStateMachine: (self: RaceSpeedService, player: Player) -> ({ [any]: any }?),
	_getAllPlayersStateMachines: (self: RaceSpeedService) -> ({ [Player]: { [any]: any } }),

	_playersStates: { [Player]: {[any]: any} },
	_setPlayerSpeed: (player: Player, speed: number) -> (),
}

local RaceSpeedService = Knit.CreateService({
	Name = "RaceSpeedService",
	Client = {},
})

function RaceSpeedService.KnitInit(self: RaceSpeedService)
	self._playersStates = {}
end

function RaceSpeedService.BoostPlayer(self: RaceSpeedService, player: Player)
	local stateMachine = self:_getPlayerStateMachine(player)

	if not stateMachine then
		self:CreateStateMachineForPlayer(player)
		stateMachine = self:_getPlayerStateMachine(player)
	end

	if stateMachine then
		stateMachine:Send("startBoost")
		task.wait()
		stateMachine:Send("stopBoost")
	end
end

function RaceSpeedService.StartStateMachines(self: RaceSpeedService)
	for _, stateMachine in pairs(self:_getAllPlayersStateMachines()) do
		stateMachine:Start()
	end
end

function RaceSpeedService.StopStateMachines(self: RaceSpeedService)
	for _, stateMachine in pairs(self:_getAllPlayersStateMachines()) do
		stateMachine:Stop()
	end
end

function RaceSpeedService.CreateStateMachineForPlayer(self: RaceSpeedService, player: Player)
	local states = self:_getAllPlayersStateMachines()
	local stateMachine = Arch.createMachine({
		id = "race_speed_machine_".. player.Name,
		initial = "default",

		states = {
			default = {
				onEntry = function()
					self._setPlayerSpeed(player, DEFAULT_SPEED)
				end,
				events = {
					startBoost = "boosted",
				}
			},
			boosted = {
				onEntry = function()
					self._setPlayerSpeed(player, BOOSTED_SPEED)
				end,
				events = {
					stopBoost = { target = "default", delay = BOOST_DURATION },
				}
			}
		}
	})

	states[player] = stateMachine
end

function RaceSpeedService._getPlayerStateMachine(self: RaceSpeedService, player: Player): { [any]: any }?
	local states = self:_getAllPlayersStateMachines()

	return states[player]
end

function RaceSpeedService._getAllPlayersStateMachines(self: RaceSpeedService): { [Player]: { [any]: any } }
	return self._playersStates
end

function RaceSpeedService._setPlayerSpeed(player: Player, speed: number)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	humanoid.WalkSpeed = speed
end

return RaceSpeedService