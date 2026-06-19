local Knit = require("@Packages/Knit")
local types = require("../../types")

type RaceTapService = types.RaceTapService

local RaceTapService = Knit.CreateService({
	Name = "RaceTapService",
	Client = {},
})

function RaceTapService.KnitInit(self: RaceTapService)
	self:_setProperties()
end

function RaceTapService.Client.SetSpeed(self, player: Player, speed: number)
	self.Server:SetSpeed(player, speed)
end

function RaceTapService.SetSpeed(self: RaceTapService, player: Player, speed: number)
	local playersSpeed = self:GetAllPlayersSpeed()

	playersSpeed[player] = speed
end

function RaceTapService.GetSpeed(self: RaceTapService, player: Player): number
	local playersSpeed = self:GetAllPlayersSpeed()

	return playersSpeed[player] or 0
end

function RaceTapService.GetAllPlayersSpeed(self: RaceTapService)
	return self._playersSpeed
end

function RaceTapService._setProperties(self: RaceTapService)
	self._playersSpeed = {}
end

return RaceTapService
