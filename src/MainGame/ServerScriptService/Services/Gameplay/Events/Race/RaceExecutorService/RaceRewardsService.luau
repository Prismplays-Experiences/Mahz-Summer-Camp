local RaceInfo = require("@Info/Events/RaceInfo")
local Knit = require("@Packages/Knit")
local Assets = require("@Assets")

local types = require("./types")

type RaceRewardsService = types.RaceRewardsService

local WON_SOUND = Assets.sounds.Events.Race.Won
local FIRST_PLACE_WEIGHT_LOSS = RaceInfo.eventProps.firstPlaceWeightLoss

local RaceRewardsService = Knit.CreateService({
	Name = "RaceRewardsService",
	Client = {},
})

function RaceRewardsService.KnitStart(self: RaceRewardsService): ()
	self._raceProgressService = Knit.GetService("RaceProgressService")
end

function RaceRewardsService.GiveRewards(self: RaceRewardsService): ()
	local leaders = self:_getLeaders()
	local playersQuantity = #leaders

	for playerPlace, info in pairs(leaders) do
		local player = info.player

		local weightLoss = self._calculateWeightLoss(playerPlace, playersQuantity)
		local lifesLoss = self._calculateLifesLoss(playerPlace, playersQuantity)

		self._giveWeightLoss(player, weightLoss)
		self._giveLifesLoss(player, lifesLoss)
	end

	local winner = leaders[1]

	if winner then
		local soundPlayerService = Knit.GetService("SoundPlayerService")
		soundPlayerService:PlaySoundById(WON_SOUND, winner.player)
	end
end

function RaceRewardsService._getLeaders(self: RaceRewardsService): ()
	local leaders = self._raceProgressService:GetLeaderboard()

	return leaders
end

function RaceRewardsService._calculateWeightLoss(playerPlace: number, playersQuantity: number): number
	playerPlace = if playerPlace == 1 then 0 else playerPlace

	local weightMultiplier = (playersQuantity - playerPlace) / playersQuantity
	local weightLoss = FIRST_PLACE_WEIGHT_LOSS * weightMultiplier

	return weightLoss
end

function RaceRewardsService._calculateLifesLoss(playerPlace: number, playersQuantity: number): number
	local lifesLoss = 0

	if playerPlace == playersQuantity and playersQuantity ~= 1 then
		lifesLoss = 1
	end

	return lifesLoss
end

function RaceRewardsService._giveWeightLoss(player: Player, weightLoss: number): ()
	local leaderstats = player:WaitForChild("leaderstats") :: Folder
	local weight = leaderstats:WaitForChild("Weight") :: IntValue

	weight.Value -= weightLoss
end

function RaceRewardsService._giveLifesLoss(player: Player, lifesLoss: number): ()
	local leaderstats = player:WaitForChild("leaderstats") :: Folder
	local lifes = leaderstats:WaitForChild("Lifes") :: IntValue

	lifes.Value -= lifesLoss
end

return RaceRewardsService
