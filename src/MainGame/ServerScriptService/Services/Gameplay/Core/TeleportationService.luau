local Signal = require("@Packages/Signal")
local Knit = require("@Packages/Knit")

export type TeleportationService = {
	PlayerTeleported: Signal.Signal<Player>,

	TeleportPlayersToPosition: (self: TeleportationService, players: { Player }, position: Vector3) -> { Player },
	TeleportByPlayersPositionsDictionary: (
		self: TeleportationService,
		playersPositionsDictionary: { [Player]: Vector3 }
	) -> { Player },
	TeleportOnePlayerToPosition: (self: TeleportationService, player: Player, position: Vector3) -> boolean,

	_createSignals: (self: TeleportationService) -> (),
}

local TeleportationService = Knit.CreateService({
	Name = "TeleportationService",
	Client = {},
})

function TeleportationService.KnitInit(self: TeleportationService)
	self:_createSignals()
end

function TeleportationService.TeleportByPlayersPositionsDictionary(
	self: TeleportationService,
	playersPositionsDictionary: { [Player]: Vector3 }
)
	local playersTeleported = {}

	for player, position in pairs(playersPositionsDictionary) do
		local isTeleported = self:TeleportOnePlayerToPosition(player, position)

		if isTeleported then
			table.insert(playersTeleported, player)
		end
	end

	return playersTeleported
end

function TeleportationService.TeleportPlayersToPosition(
	self: TeleportationService,
	players: { Player },
	position: Vector3
)
	local playersTeleported = {}

	for _, player in pairs(players) do
		local isTeleported = self:TeleportOnePlayerToPosition(player, position)

		if isTeleported then
			table.insert(playersTeleported, player)
		end
	end

	return playersTeleported
end

function TeleportationService.TeleportOnePlayerToPosition(self: TeleportationService, player: Player, position: Vector3)
	local character = player.Character

	if not character then
		return false
	end

	character:PivotTo(CFrame.new(position))

	self.PlayerTeleported:Fire(player)

	return true
end

function TeleportationService._createSignals(self: TeleportationService)
	self.PlayerTeleported = Signal.new()
end

return TeleportationService
