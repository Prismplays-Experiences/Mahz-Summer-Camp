local GeneralInfo = require(game.ReplicatedStorage.Info.GeneralInfo)

function CreateTarget(Day, IdealStrength, MaxDays)
	MaxDays = MaxDays or GeneralInfo.MaxDays
	local k = 0.15 -- curve steepness
	local roundTo = 5

	local rawStrengths = {}
	local totalRaw = 0

	-- Step 1: Generate exponential Strengths
	for i = 1, MaxDays do
		local w = math.exp(k * i)
		table.insert(rawStrengths, w)
		totalRaw += w
	end

	-- Step 2: Scale and round Strengths
	local scale = IdealStrength / totalRaw
	local scaledStrengths = {}
	local roundedStrengths = {}
	local totalRounded = 0

	for i = 1, MaxDays do
		local scaled = rawStrengths[i] * scale
		scaledStrengths[i] = scaled
		local rounded = math.floor((scaled / roundTo) + 0.5) * roundTo
		roundedStrengths[i] = rounded
		totalRounded += rounded
	end

	-- Step 3: Fix rounding error by adjusting largest Strengths
	local difference = IdealStrength - totalRounded
	local adjustmentStep = roundTo * (difference > 0 and 1 or -1)
	local remaining = math.abs(difference)

	while remaining > 0 do
		for i = MaxDays, 1, -1 do
			local newValue = roundedStrengths[i] + adjustmentStep
			if newValue >= 0 then
				roundedStrengths[i] = newValue
				remaining -= roundTo
				if remaining <= 0 then
					break
				end
			end
		end
	end

	-- Step 4: Return the value for the requested day
	return roundedStrengths[Day]
end

return {
	Day1 = {
		"Welcome to Prism Gym!",
		"You got chunky...",
		"and pudgy...",
		`now you have {GeneralInfo.MaxDays} days to get shredded!`,
		`Lose {GeneralInfo.Strength} lbs or... it's game over.`,
		`You are tasked with losing {math.round(
			CreateTarget(1, GeneralInfo.Strength - GeneralInfo.EndStrength, GeneralInfo.MaxDays)
		)} lbs today!`,
		"Go Now!",
	},

	-- Day1 = {
	--     'Arise Fellas!',
	--     `You are tasked with losing {math.round(CreateTarget(1, GeneralInfo.Strength- GeneralInfo.EndStrength, GeneralInfo.MaxDays))} lbs today!`,
	--     `Use the workout equipments to lose Strength.`,
	--     'LETS GOO!!',
	-- },
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
		" Day 3, baby!",
		"Time to spice it up!",
		"Random events are now live!",
		"They might chunk you up...",
		"or slim you down!",
		"A new event hits every 2 days",
		"From Devs: (We aim to have a new event everyday, we are working on it!)",
		"Goodluck!!",
	},

	Winners = {
		" YOU DID IT!",
		"You're officially a Prism Gym legend!",
		"That grind? Unreal.",
		"You're built different.",
		"But don't stop here...",
		"Fitness is a journey, not a destination!",
		"Thanks for playing 💖",
		"From Devs: (You're cracked. New content coming soon!)",
	},

	Eliminated = {
		"A player has been eliminated!",
	},
}
