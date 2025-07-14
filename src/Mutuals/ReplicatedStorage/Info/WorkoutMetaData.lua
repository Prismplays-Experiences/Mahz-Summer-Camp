local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Assets = ReplicatedStorage:WaitForChild('Assets')
local WorkoutTools = Assets:WaitForChild('WorkoutTools')
return{

    Pushups = {
        MinWeightLoss = 1,
        MaxWeightLoss = 1,
        AnimationId = 'rbxassetid://90718551251909',
        ConstantSound = nil,
        RepCountSound = nil,
        ObjectText = '1 lbs per rep',
        ActionText = 'Pushups',
        Minigame = 'TapScreen',
        Level = nil,
        Resolution = 0.1,
    },
    Treadmill = {
        MinWeightLoss = 2,
        MaxWeightLoss = 4,
        AnimationId = 'rbxassetid://90258052759623',
        ConstantSound = nil,
        RepCountSound = nil,
        ObjectText = '2 to 4lbs per rep',
        ActionText = 'Running',
        Minigame = 'TapScreen',
        Level = nil,
    },
    DumbellCurl = {
        MinWeightLoss = 5,
        MaxWeightLoss = 9,
        AnimationId = 'rbxassetid://86790780787475',
        ConstantSound = nil,
        RepCountSound = nil,
        ObjectText = '5 to 9lbs per rep',
        ActionText = 'Dumbell Curl',
        Minigame = 'ObjectValues',
        Level = 1,
        Tool = WorkoutTools:WaitForChild('Dumbells'),
    },
    BenchPress = {
        MinWeightLoss = 10,
        MaxWeightLoss = 15,
        AnimationId = 'rbxassetid://136624430039075',
        ConstantSound = nil,
        RepCountSound = nil,
        ObjectText = '10 to 15lbs per rep',
        ActionText = 'Bench Press',
        Minigame = 'ObjectValues',
        Level = 2,
        Tool = WorkoutTools:WaitForChild('Barbell'),
    },

    Dips = {
        MinWeightLoss = 17,
        MaxWeightLoss = 23,
        AnimationId = 'rbxassetid://90142283745294',
        ConstantSound = nil,
        RepCountSound = nil,
        ObjectText = '17 to 23lbs per rep',
        ActionText = 'Dips',
        Minigame = 'ObjectValues',
        Level = 2,
    },

    

    
}