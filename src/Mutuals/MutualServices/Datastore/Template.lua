local DailyReward = {
	Due = true,
	Streak = 1,
	lastonline = '',
	ClaimedReward = false,
}

local leaderstats = {
	Wins = 0;
	Loses = 0;
}

local PrivateStats = {
	
	Spins = 0;
	Currency = 50;
	TutorialConcluded = false;
	Donate = 0;
	RobuxSpent = 0;
	TimePlayed = 0;
	GroupReward = false;
	Lifes = 1;
}



local StatusData = {
	NewUser = true,
	ClaimedGroupRewards = false,
}

local Inventory = {
	Trails = '',
}

local EquippedItems = {
	Trails = '';
}

local DataTemplate = {
	DailyReward = DailyReward;
	leaderstats = leaderstats;
	StatusData = StatusData;
	PrivateStats = PrivateStats;
	Inventory = Inventory;
	EquippedItems = EquippedItems;
}

return DataTemplate
