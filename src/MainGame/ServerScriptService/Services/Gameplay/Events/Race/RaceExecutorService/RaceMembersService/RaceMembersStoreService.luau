local Knit = require("@Packages/Knit")
local types = require("../types")

type RaceMembersStoreService = types.RaceMembersStoreService

local RaceMembersStoreService = Knit.CreateService({
	Name = "RaceMembersStoreService",
	Client = {},
})

function RaceMembersStoreService.KnitInit(self: RaceMembersStoreService)
	self._players = {}
end

function RaceMembersStoreService.AddPlayer(self: RaceMembersStoreService, player: Player)
	local players = self:GetPlayers()

	table.insert(players, player)
end

function RaceMembersStoreService.RemovePlayer(self: RaceMembersStoreService, player: Player)
	local players = self:GetPlayers()

	table.remove(players, table.find(players, player))
end

function RaceMembersStoreService.IsPlayerInRace(self: RaceMembersStoreService, player: Player)
	local players = self:GetPlayers()

	return table.find(players, player) ~= nil
end

function RaceMembersStoreService.GetPlayers(self: RaceMembersStoreService)
	return self._players
end

return RaceMembersStoreService
