local Players = game:GetService("Players")

local RaceInfo = require("@Info/Events/RaceInfo")
local Knit = require("@Packages/Knit")
local types = require("./types")

local RACE_START_POSITION = RaceInfo.teleportation.raceStartPosition
local MAP_CENTER_POSITION = RaceInfo.teleportation.mapCenterPosition

type RaceMembersService = types.RaceMembersService

local RaceMembersService = Knit.CreateService({
	Name = "RaceMembersService",
	Client = {}
})

function RaceMembersService.KnitStart(self: RaceMembersService)
	self.raceMembersStoreService = Knit.GetService("RaceMembersStoreService")
	self.teleportationService = Knit.GetService("TeleportationService")
	self.raceSpeedService = Knit.GetService("RaceSpeedService")
end

function RaceMembersService.AddAllPlayers(self: RaceMembersService)
	local players = Players:GetPlayers()

	for _, player in pairs(players) do
		self:AddPlayer(player)
	end

	self.raceSpeedService:StartForEveryone(players)
end

function RaceMembersService.RemoveAllPlayers(self: RaceMembersService)
	for _, player in self:GetPlayers() do
		self:RemovePlayer(player)
	end

	self.raceSpeedService:Stop()
end

function RaceMembersService.AddPlayer(self: RaceMembersService, player: Player)
	self.raceMembersStoreService:AddPlayer(player)
	self.teleportationService:TeleportOnePlayerToPosition(player, RACE_START_POSITION)
	self.raceSpeedService:CreateStateMachineForPlayer(player)
end

function RaceMembersService.RemovePlayer(self: RaceMembersService, player: Player)
	self.raceMembersStoreService:RemovePlayer(player)
	self.teleportationService:TeleportOnePlayerToPosition(player, MAP_CENTER_POSITION)
end

function RaceMembersService.IsPlayerInRace(self: RaceMembersService, player: Player)
	return self.raceMembersStoreService:IsPlayerInRace(player)
end

function RaceMembersService.GetPlayers(self: RaceMembersService)
	return self.raceMembersStoreService:GetPlayers()
end

return RaceMembersService