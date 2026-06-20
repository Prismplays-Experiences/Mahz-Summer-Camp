local Knit = require("@Packages/Knit")
return {
	Suppliments = {
		StrengthGainShield = {
			Cost = 75,
			ProductId = 3346296359,
			Name = "Strength Loss Shield",
			Description = "Protects from Strength loss",
			Image = "rbxassetid://101769566551705",
			ToolName = "StrengthGainShield",
			Duration = 60,
			func = function(Player)
				local SupplimentsService = Knit.GetService("SupplimentsService")
				SupplimentsService:UseSuppliment(Player, game.ServerStorage.Suppliments.StrengthGainShield, 60)
			end,
			Rarity = "Common",
		},
		RecoveryBox = {
			Cost = 75,
			ProductId = 3346296363,
			Name = "Recovery Box",
			Description = "Speed recovery from injuries",
			Image = "rbxassetid://98857439835677",
			ToolName = "RecoveryBox",
			Increment = 35,
			func = function(Player)
				local SupplimentsService = Knit.GetService("SupplimentsService")
				SupplimentsService:RecoverHealth(Player, 35)
			end,
			Rarity = "Common",
		},
		["CaffeinePill"] = {
			Cost = 100,
			ProductId = 3346296360,
			Multiplier = 1.2,
			Name = "Caffeine Pill",
			Description = "1.2x Workout Speed",
			Image = "rbxassetid://86531079850603",
			ToolName = "CaffeinePill",
			Duration = 30,
			func = function(Player)
				local SupplimentsService = Knit.GetService("SupplimentsService")
				SupplimentsService:UseSuppliment(Player, game.ServerStorage.Suppliments.CaffeinePill, 60)
			end,
			Rarity = "Common",
		},

		["FiberSupplement"] = {
			Cost = 225,
			ProductId = 3346296362,
			Name = "Fiber Supplement",
			Multipler = 2,
			Description = "2x Strength Gain from food",
			Image = "rbxassetid://71958273625233",
			ToolName = "FiberSupplement",
			Duration = 2 * 60,
			func = function(Player)
				local SupplimentsService = Knit.GetService("SupplimentsService")
				SupplimentsService:UseSuppliment(Player, game.ServerStorage.Suppliments.FiberSupplement, 60)
			end,
			Rarity = "Uncommon",
		},
		["HyperShredMax"] = {
			Cost = 1250,
			ProductId = 3346296368,
			Multiplier = 2,
			Name = "Hyper Shred Max",
			Description = "2x Strength Gain, 2x Workout Speed, 2x Health Recovery",
			Image = "rbxassetid://126794628962455",
			ToolName = "HyperShredMax",
			Duration = 1 * 60,
			func = function(Player)
				local SupplimentsService = Knit.GetService("SupplimentsService")
				SupplimentsService:UseSuppliment(Player, game.ServerStorage.Suppliments.HyperShredMax, 180)
			end,
			Rarity = "Legendary",
		},

		FatBurner = {
			Cost = 550,
			ProductId = 3346296361,
			Name = "Fat Burner",
			Multiplier = 1.5,
			Description = "1.5x Strength Gain from workouts",
			Image = "rbxassetid://92795872550388",
			ToolName = "FatBurner",
			Duration = 1.5 * 60,
			func = function(Player)
				local SupplimentsService = Knit.GetService("SupplimentsService")
				SupplimentsService:UseSuppliment(Player, game.ServerStorage.Suppliments.FatBurner, 60)
			end,
			Rarity = "Rare",
		},
	},
	Auras = {
		HardWorkFlame = {
			Cost = 95,
			ProductId = 3358019721,
			Name = "Hard Work Flame",
			Description = "Increases motivation",
			Image = "rbxassetid://91179031017733",
			ToolName = "HardWorkFlame",
			Rarity = "Common",
		},
		HotFlame = {
			Cost = 135,
			ProductId = 3358019407,
			Name = "Very Hot Flame",
			Description = "Increases motivation",
			Image = "rbxassetid://105153839073359",
			ToolName = "HotFlame",
			Rarity = "Uncommon",
		},
		AngryBloodMist = {
			Cost = 350,
			ProductId = 3358024027,
			Name = "Angry Blood Mist",
			Description = "Show the world how angry you are",
			Image = "rbxassetid://95363264349288",
			ToolName = "AngryBloodMist",
			Rarity = "Rare",
		},
		GodAuraFlame = {
			Cost = 1050,
			ProductId = 3358028217,
			Name = "God Aura",
			Description = "You own the place",
			Image = "rbxassetid://107004619567088",
			ToolName = "GodAuraFlame",
			Rarity = "Legendary",
		},
	},
	Events = {
		["FoodChaos"] = {
			Cost = 100,
			ProductId = 3358496424,
			Name = "Food Chaos",
			Description = "Avoid the bad food, eat the good food",
			Image = "rbxassetid://74060213881216",
			EventName = "FoodChaos",
			Rarity = "Common",
		},
		["FoodBomb"] = {
			Cost = 175,
			ProductId = 3358496772,
			Name = "Food Bomb",
			Description = "Avoid the bad food bomb",
			Image = "rbxassetid://70526751887027",
			EventName = "FoodBomb",
			Rarity = "Uncommon",
		},
		-- ["1800mSprint"] = {
		-- 	Cost = 250,
		-- 	ProductId = 3360952251,
		-- 	Name = "1800mSprint",
		-- 	Description = "Race 1800 meters against others",
		-- 	Image = "rbxassetid://94937288830539",
		-- 	EventName = "Race",
		-- 	Rarity = "Rare",
		-- },
	},
}
