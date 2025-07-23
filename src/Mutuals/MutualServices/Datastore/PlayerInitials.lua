local PlayerInitials = {}
-- local CollectionService = game:GetService('CollectionService')
-- local MarketplaceService = game:GetService('MarketplaceService')
local ExperienceInfo = require("@Info/ExperienceInfo")
local GeneralInfo = require("@Info/GeneralInfo")

local placeId = require("@Info/PlaceId").Get()

function Create_INST(TYPE: string, PARENT, NAME: string)
	local NewINST = Instance.new(TYPE)
	NewINST.Parent = PARENT
	NewINST.Name = NAME
	return NewINST
end

function UpdateValues(Value, DataSet, DataString)
	if DataSet[DataString] == nil then
		warn(DataSet, DataString)
	end
	Value.Value = DataSet[DataString]
	Value:GetPropertyChangedSignal("Value"):Connect(function()
		DataSet[DataString] = Value.Value
	end)
end

-- local function banPlayer(userId, duration, displayReason, privateReason)
-- 	pcall(function()
-- 		game.Players:BanAsync({
-- 			UserIds = { userId }, -- List of UserIds to ban
-- 			ApplyToUniverse = true, -- Apply ban across the entire game universe
-- 			Duration = duration, -- Duration in seconds (-1 for permanent ban)
-- 			DisplayReason = displayReason, -- Reason shown to the player
-- 			PrivateReason = privateReason, -- Reason visible only to developers
-- 			ExcludeAltAccounts = true, -- Also ban suspected alternate accounts
-- 		})
-- 	end)
-- end

-- function BanPlrForHacking(plr)
-- 	banPlayer(plr.UserId,-1,'You thought I wouldnt get you?🤡 ', 'Hacking')
-- end

function PlayerInitials:Create(player: Player, profile)
	Create_INST("BoolValue", player, "DataLoaded")
	--Starter
	local StatusData = Create_INST("Folder", player, "StatusData")
	local NewUser = Create_INST("BoolValue", StatusData, "NewUser")
	local ClaimedGroupRewards = Create_INST("BoolValue", StatusData, "ClaimedGroupRewards")
	UpdateValues(NewUser, profile.Data.StatusData, "NewUser")
	UpdateValues(ClaimedGroupRewards, profile.Data.StatusData, "ClaimedGroupRewards")

	--// Daily Reward
	local DailyRewardInst = Create_INST("Folder", player, "DailyRewardInst")
	local Due = Create_INST("BoolValue", DailyRewardInst, "Due")
	local Streak = Create_INST("IntValue", DailyRewardInst, "Streak")
	local lastonline = Create_INST("StringValue", DailyRewardInst, "lastonline")
	local ClaimedReward = Create_INST("BoolValue", DailyRewardInst, "ClaimedReward")

	UpdateValues(Due, profile.Data.DailyReward, "Due")
	UpdateValues(Streak, profile.Data.DailyReward, "Streak")
	UpdateValues(lastonline, profile.Data.DailyReward, "lastonline")
	UpdateValues(ClaimedReward, profile.Data.DailyReward, "ClaimedReward")

	--//leaderstats
	local leaderstats = Create_INST("Folder", player, "leaderstats")
	local Wins = Create_INST("IntValue", leaderstats, "Wins")
	local Loses = Create_INST("IntValue", leaderstats, "Loses")

	UpdateValues(Wins, profile.Data.leaderstats, "Wins")
	UpdateValues(Loses, profile.Data.leaderstats, "Loses")

	--//PrivateStats
	local PrivateStats = Create_INST("Folder", player, "PrivateStats")
	local Currency = Create_INST("IntValue", PrivateStats, "Currency")
	Create_INST("IntValue", PrivateStats, "LockedCap")
	local Spins = Create_INST("IntValue", PrivateStats, "Spins")
	local TimePlayed = Create_INST("IntValue", PrivateStats, "TimePlayed")
	local RobuxSpent = Create_INST("IntValue", PrivateStats, "RobuxSpent")
	local GroupReward = Create_INST("BoolValue", PrivateStats, "GroupReward")
	local Donate = Create_INST("IntValue", PrivateStats, "Donate")
	local Lifes = Create_INST("IntValue", PrivateStats, "Lifes")
	UpdateValues(Lifes, profile.Data.PrivateStats, "Lifes")
	local TutorialConcluded = Create_INST("BoolValue", PrivateStats, "TutorialConcluded")

	if ExperienceInfo.Places.MainGame.Id == placeId then
		Lifes = Create_INST("IntValue", leaderstats, "Lifes")
		Lifes.Value = GeneralInfo.MaxLifes
	end
	UpdateValues(Donate, profile.Data.PrivateStats, "Donate")
	UpdateValues(Currency, profile.Data.PrivateStats, "Currency")
	UpdateValues(Spins, profile.Data.PrivateStats, "Spins")
	UpdateValues(TimePlayed, profile.Data.PrivateStats, "TimePlayed")
	UpdateValues(RobuxSpent, profile.Data.PrivateStats, "RobuxSpent")
	UpdateValues(GroupReward, profile.Data.PrivateStats, "GroupReward")
	UpdateValues(TutorialConcluded, profile.Data.PrivateStats, "TutorialConcluded")

	--// Inventory
	local Inventory = Create_INST("Folder", player, "Inventory")
	local TrailsInventory = Create_INST("StringValue", Inventory, "Trails")

	UpdateValues(TrailsInventory, profile.Data.Inventory, "Trails")

	--Equipped Items
	local EquippedItems = Create_INST("Folder", player, "EquippedItems")
	local Trails = Create_INST("StringValue", EquippedItems, "Trails")

	UpdateValues(Trails, profile.Data.EquippedItems, "Trails")

	coroutine.wrap(function()
		while task.wait(1) do
			if not player:IsDescendantOf(game:GetService("Players")) then
				return
			end
			TimePlayed.Value += 1
			-- player:WaitForChild("PrivateStats").TimeSpent.Value+=1
		end
	end)()

	local dataLoaded = player:WaitForChild("DataLoaded") :: BoolValue
	dataLoaded.Value = true
end

return PlayerInitials
