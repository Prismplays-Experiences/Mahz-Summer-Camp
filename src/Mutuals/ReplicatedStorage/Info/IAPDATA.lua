local Knit = require("@Packages/Knit")
return {
	Suppliments = {
		WeightGainShield = {
			Cost = 75,
			ProductId = 3346296359,
			Name = "Weight Gain Shield",
			Description = "Protects from weight gain",
			Image = "rbxassetid://101769566551705",
			ToolName = "WeightGainShield",
			Duration = 60,
			func = function(Player)
				local SupplimentsService = Knit.GetService("SupplimentsService")
				SupplimentsService:UseSuppliment(Player, game.ServerStorage.Suppliments.WeightGainShield, 60)
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
			Description = "2x weight loss from food",
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
			Description = "2x weight loss, 2x Workout Speed, 2x Health Recovery",
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
			Description = "1.5x weight loss from workouts",
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
	Events = {},
	Auras = {},
}
