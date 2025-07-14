return {
    Foods = {
        ['Apple'] = {
            Name = 'Apple',
            DefaultWeightLoss = 10,
        },
        ['Carrot'] = {
            Name = 'Carrot',
            DefaultWeightLoss = 8,
        },
        ['Potato'] = {
            Name = 'Potato',
            DefaultWeightLoss = 4,
        },
        ['Tomato'] = {
            Name = 'Tomato',
            DefaultWeightLoss = 7,
        },
        ['Onion'] = {
            Name = 'Onion',
            DefaultWeightLoss = 5,
        },
        ['Burger'] = {
            Name = 'Burger',
            DefaultWeightLoss = -15, -- makes you gain weight
        },
        ['Fries'] = {
            Name = 'Fries',
            DefaultWeightLoss = -10,
        },
        ['IceCream'] = {
            Name = 'IceCream',
            DefaultWeightLoss = -12,
        },
        ['Pizza'] = {
            Name = 'Pizza',
            DefaultWeightLoss = -18,
        },
    },

    Info = {
        ['HighFoodWeightLoss'] = 35,
        ['FoodWeightLossIntervalMin'] = 2,
        ['FoodWeightLossIntervalMax'] = 100, -- determine max interval based on the day
        ['WeightIntervalResolution'] = 10,
        ['MaxWeightLoss'] = 100,
        ['MinWeightLoss'] = 2,
    },
}