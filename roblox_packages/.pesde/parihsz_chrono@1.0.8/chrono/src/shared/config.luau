return table.freeze({
	MIN_BUFFER = 0.09,
	MAX_BUFFER = 0.5,
	TICK_RATE = 1 / 20,

	PROXIMITY = 100,

	ENABLE_CUSTOM_CHARACTERS = false, -- this will disable default roblox replication as well.
	DISABLE_DEFAULT_REPLICATION = false, -- this is if you want to disable the default roblox replication, but still use their controller

	NPC_TYPES = table.freeze({
		DEFAULT = table.freeze({
			TICK_RATE = 1 / 30,
			BUFFER = 0.1,
		}),
	}),
})
