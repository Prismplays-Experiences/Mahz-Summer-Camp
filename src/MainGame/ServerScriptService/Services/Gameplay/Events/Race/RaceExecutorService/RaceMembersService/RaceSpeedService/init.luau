local RunService = game:GetService("RunService")

local Knit = require("@Packages/Knit")
local Trove = require("@Packages/Trove")
local types = require("../types")

local DEFAULT_SPEED = 16

type RaceSpeedService = types.RaceSpeedService

local RaceSpeedService = Knit.CreateService({
	Name = "RaceSpeedService",
	Client = {},
})

function RaceSpeedService.KnitInit(self: RaceSpeedService)
	self:_setProperties()
end

function RaceSpeedService.CreateStateMachineForPlayer(self: RaceSpeedService, player: Player)
	self._raceSpeedStateService:CreateStateMachineForPlayer(player)
end

function RaceSpeedService.StartForEveryone(self: RaceSpeedService, players: {Player})
	for _, player in pairs(players) do
		self:_connectEvents(player)
	end

	self._raceSpeedStateService:StartStateMachines()
end

function RaceSpeedService.Start(self: RaceSpeedService, player: Player): ()
	self:_connectEvents(player)
end

function RaceSpeedService.Stop(self: RaceSpeedService): ()
	self:_cleanTrove()
	self._raceSpeedStateService:StopStateMachines()
end

function RaceSpeedService.GetPlayerSpeed(self: RaceSpeedService, player: Player): number
	local tapSpeed = self._raceTapService:GetSpeed(player)
	local boostSpeed = self._raceSpeedStateService:GetSpeed(player)

	local totalSpeed = tapSpeed + boostSpeed + DEFAULT_SPEED

	return totalSpeed
end

function RaceSpeedService._setProperties(self: RaceSpeedService)
	self._raceTapService = Knit.GetService("RaceTapService")
	self._raceSpeedStateService = Knit.GetService("RaceSpeedStateService")
	self._trove = Trove.new()
end

function RaceSpeedService._connectEvents(self: RaceSpeedService, player: Player)
	local trove = self:_getTrove()
	local currentTime = 0.2

	trove:Connect(RunService.Heartbeat, function(deltaTime: number)
		currentTime = currentTime + deltaTime

		if currentTime < 0.2 then
			return
		end

		local speed = self:GetPlayerSpeed(player)
		local character = player.Character :: Model & { Humanoid: Humanoid? }

		if not character then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")

		if not humanoid then
			return
		end

		humanoid.WalkSpeed = speed
	end)
end

function RaceSpeedService._cleanTrove(self: RaceSpeedService)
	local trove = self:_getTrove()

	trove:Clean()
end

function RaceSpeedService._getTrove(self: RaceSpeedService): Trove.Trove
	return self._trove
end

return RaceSpeedService
