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
        ObjectText = '',
        ActionText = '',
        Minigame = 'ObjectValues',
        Level = 1,
        Resolution = 0.1,
    },
    Treadmill = {
        MinWeightLoss = 2,
        MaxWeightLoss = 4,
        AnimationId = 'rbxassetid://90258052759623',
        ConstantSound = nil,
        RepCountSound = nil,
        ObjectText = '',
        ActionText = '',
        Minigame = 'TapScreen',
        Level = nil,
    },
    DumbellCurl = {
        MinWeightLoss = 5,
        MaxWeightLoss = 9,
        AnimationId = 'rbxassetid://86790780787475',
        ConstantSound = nil,
        RepCountSound = nil,
        ObjectText = '',
        ActionText = '',
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
        ObjectText = '',
        ActionText = '',
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
        ObjectText = '',
        ActionText = '',
        Minigame = 'ObjectValues',
        Level = 2,
    },

    

    
}