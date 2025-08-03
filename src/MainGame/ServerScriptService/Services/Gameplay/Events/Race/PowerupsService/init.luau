local Knit = require("@Packages/Knit")
local types = require("./types")

type PowerupsService = types.PowerupsService

local PowerupsService = Knit.CreateService({
	Name = "PowerupsService",
	Client = {
		PowerupReceived = Knit.CreateSignal("PowerupReceived"),
	},
})

function PowerupsService.KnitInit(self: PowerupsService)
	self._powerups = {}
end

function PowerupsService.Client.Use(self: {Server: PowerupsService}, player: Player): boolean
	return self.Server:Use(player)
end

function PowerupsService.Give(self: PowerupsService, player: Player, powerupName: string)
	local powerups = self:GetPowerups()

	if not powerups[player] then
		powerups[player] = powerupName
		self.Client.PowerupReceived:Fire(player, powerupName)
	else
		warn("Player already has a powerup assigned.")
	end
end

function PowerupsService.Use(self: PowerupsService, player: Player): boolean
	local powerups = self:GetPowerups()

	if powerups[player] then
		powerups[player] = nil

		return true
	else
		warn("Player does not have a powerup to use.")

		return false
	end
end

function PowerupsService.GetPowerups(self: PowerupsService): { [Player]: string }
	return self._powerups
end

return PowerupsService