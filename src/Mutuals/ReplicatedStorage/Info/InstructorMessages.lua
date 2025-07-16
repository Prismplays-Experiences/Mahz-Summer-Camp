local GeneralInfo = require(game.ReplicatedStorage.Info.GeneralInfo)

function CreateTarget(Day, IdealWeight, MaxDays)
    MaxDays = MaxDays or GeneralInfo.MaxDays
    local k = 0.15 -- curve steepness
    local roundTo = 5

    local rawWeights = {}
    local totalRaw = 0

    -- Step 1: Generate exponential weights
    for i = 1, MaxDays do
        local w = math.exp(k * i)
        table.insert(rawWeights, w)
        totalRaw += w
    end

    -- Step 2: Scale and round weights
    local scale = IdealWeight / totalRaw
    local scaledWeights = {}
    local roundedWeights = {}
    local totalRounded = 0

    for i = 1, MaxDays do
        local scaled = rawWeights[i] * scale
        scaledWeights[i] = scaled
        local rounded = math.floor((scaled / roundTo) + 0.5) * roundTo
        roundedWeights[i] = rounded
        totalRounded += rounded
    end

    -- Step 3: Fix rounding error by adjusting largest weights
    local difference = IdealWeight - totalRounded
    local adjustmentStep = roundTo * (difference > 0 and 1 or -1)
    local remaining = math.abs(difference)

    while remaining > 0 do
        for i = MaxDays, 1, -1 do
            local newValue = roundedWeights[i] + adjustmentStep
            if newValue >= 0 then
                roundedWeights[i] = newValue
                remaining -= roundTo
                if remaining <= 0 then break end
            end
        end
    end

    -- Step 4: Return the value for the requested day
    return roundedWeights[Day]
end

return {
    Intro = {
        -- "Welcome to Prism Gym!",
        -- "You got chunky...",
        -- "and pudgy...",
        -- `now you have {GeneralInfo.MaxDays} days to get shredded!`,
        -- `Lose {GeneralInfo.Weight} lbs or... it's game over.`,
        -- `Bedtime is at 8 PM,`
        -- `You are tasked with losing {math.round(CreateTarget(1, GeneralInfo.Weight- GeneralInfo.EndWeight, GeneralInfo.MaxDays))} lbs today!`,
        -- "Go Now!",
        "Welcome to Prism Gym!",
        "You got chunky...",
        "and pudgy...",
        `now you have {GeneralInfo.MaxDays} days to get shredded!`,
        `Lose {GeneralInfo.Weight} lbs or... it's game over.`,
        "You got this, probably!",
        "Time for bed. Wake-up call at 8 AM!",
        "See ya tomorrow, champ!",
    },

    Day1 = {
        'Arise Fellas!',
        `You are tasked with losing {math.round(CreateTarget(1, GeneralInfo.Weight- GeneralInfo.EndWeight, GeneralInfo.MaxDays))} lbs today!`,
        `Use the workout equipments to lose weight.`,
        'LETS GOO!!',
    },
    Day2 = {
        "Congrats! You've made it to Day 2!",
        "I have decided to help you out a bit more!",
        "I got a chef that will cook for you!",
        "The chef cooks anything",
        "so be careful what you eat!",
        "Lunch is at 12 PM",
        "Bye!!",
    },
    Day3 = {
        ' Day 3, baby!',
        'Time to spice it up!',
        'Random events are now live!',
        'They might chunk you up...',
        'or slim you down!',
        'A new event hits every 3 days',
        'From Devs: (We aim to have a new event everyday, we are working on it!)',
        'Goodluck!!',
    },
}