local Knit = require("@Packages/Knit")
local types = require("./types")

local PowerupModuleGetter = require("./PowerupsService/PowerupModuleGetter")

type PowerupsService = types.PowerupsService

local PowerupsService = Knit.CreateService({
	Name = "PowerupsService",
	Client = {
		PowerupReceived = Knit.CreateSignal("PowerupReceived"),
	},
})

function PowerupsService.KnitStart(self: PowerupsService)
	self._powerups = {}
	self._raceProgressService = Knit.GetService("RaceProgressService")
end

function PowerupsService.Client.Use(self: {Server: PowerupsService}, player: Player): boolean
	local success = self.Server:Use(player)

	return success
end

function PowerupsService.Give(self: PowerupsService, player: Player, powerupName: string): boolean
	local powerups = self:GetAllPowerups()

	if not powerups[player] then
		self:_setPowerup(player, powerupName)

		return true
	else
		return false
	end
end

function PowerupsService.Use(self: PowerupsService, player: Player): boolean
	local powerup = self:GetPowerup(player)

	if powerup then
		local success = self:_activatePowerup(player)

		return success
	else
		warn("Player does not have a powerup to use.")

		return false
	end
end

function PowerupsService.GetAllPowerups(self: PowerupsService): { [Player]: string }
	return self._powerups
end

function PowerupsService.GetPowerup(self: PowerupsService, player: Player): string?
	return self._powerups[player]
end

function PowerupsService._activatePowerup(self: PowerupsService, player: Player): boolean
	local powerupName = self:GetPowerup(player)
	local powerup = PowerupModuleGetter.Get(powerupName)
	local nearestPlayer = self._raceProgressService:GetNearestPlayer(player)

	print("NEAREST PLAYER:", nearestPlayer and nearestPlayer.Name or "None")

	if not powerup then
		warn("Powerup module not found for:", powerupName)
		return false
	end

	local success = powerup.Activate(player, nearestPlayer)

	if success then
		self:_setPowerup(player, nil)
	else
		warn("Failed to activate powerup:", powerupName)
	end

	return success
end

function PowerupsService._setPowerup(self: PowerupsService, player: Player, powerupName: string?)
	local powerups = self:GetAllPowerups()

	powerups[player] = powerupName

	if powerupName == nil then
		return
	end

	self.Client.PowerupReceived:Fire(player, powerupName)
end

return PowerupsService