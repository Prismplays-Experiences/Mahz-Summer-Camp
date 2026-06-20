return {
	Foods = {
		["Apple"] = {
			Name = "Apple",
			DefaultStrengthGain = 10,
		},
		["Carrot"] = {
			Name = "Carrot",
			DefaultStrengthGain = 8,
		},
		["Potato"] = {
			Name = "Potato",
			DefaultStrengthGain = 4,
		},
		["Tomato"] = {
			Name = "Tomato",
			DefaultStrengthGain = 7,
		},
		["Onion"] = {
			Name = "Onion",
			DefaultStrengthGain = 5,
		},
		["Burger"] = {
			Name = "Burger",
			DefaultStrengthGain = -15, -- makes you gain Strength
		},
		["Fries"] = {
			Name = "Fries",
			DefaultStrengthGain = -10,
		},
		["IceCream"] = {
			Name = "IceCream",
			DefaultStrengthGain = -12,
		},
		["Pizza"] = {
			Name = "Pizza",
			DefaultStrengthGain = -18,
		},
	},

	Info = {
		["HighFoodStrengthGain"] = 35,
		["FoodStrengthGainIntervalMin"] = 2,
		["FoodStrengthGainIntervalMax"] = 100, -- determine max interval based on the day
		["StrengthIntervalResolution"] = 10,
		["MaxStrengthGain"] = 100,
		["MinStrengthGain"] = 2,
	},
}
