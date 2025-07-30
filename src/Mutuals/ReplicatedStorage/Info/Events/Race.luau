local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GAME_FOLDER = workspace:WaitForChild("Game")
local EVENTS_WORKSPACE_FOLDER = GAME_FOLDER:WaitForChild("ScriptingProperties"):WaitForChild("Events")
local RACE_WORKSPACE_FOLDER = EVENTS_WORKSPACE_FOLDER:WaitForChild("Track1800M")

local EVENTS_MODELS_FOLDER = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Events")
local RACE_MODELS_FOLDER = EVENTS_MODELS_FOLDER:WaitForChild("Race")

local BORDERS_FOLDER = RACE_WORKSPACE_FOLDER:WaitForChild("Borders")
local FINISH_LINE = RACE_WORKSPACE_FOLDER:WaitForChild("FinishLine")
local LANDMARKS_FOLDER = RACE_WORKSPACE_FOLDER:WaitForChild("Landmarks")
local POWERUP_TEMPLATE = RACE_MODELS_FOLDER:WaitForChild("Powerup")

local BANANA_TEMPLATE = RACE_MODELS_FOLDER:WaitForChild("Banana")
local BOMB_TEMPLATE = RACE_MODELS_FOLDER:WaitForChild("Bomb")
local SPIKES_TEMPLATE = RACE_MODELS_FOLDER:WaitForChild("Spikes")
local SMALL_ICE_BLOCK_TEMPLATE = RACE_MODELS_FOLDER:WaitForChild("SmallIceBlock")
local BIG_ICE_BLOCK_TEMPLATE = RACE_MODELS_FOLDER:WaitForChild("BigIceBlock")
local BOOST_TEMPLATE = RACE_MODELS_FOLDER:WaitForChild("Boost")

return {
	instances = {
		track = {
			bordersFolder = BORDERS_FOLDER,
			finishLine = FINISH_LINE,
			landmarksFolder = LANDMARKS_FOLDER,
		},
		powerups = {
			bananaTemplate = BANANA_TEMPLATE,
			bombTemplate = BOMB_TEMPLATE,
			smallIceBlockTemplate = SMALL_ICE_BLOCK_TEMPLATE,
		},
		spawnables = {
			powerupTemplate = POWERUP_TEMPLATE,
			spikesTemplate = SPIKES_TEMPLATE,
			boostTemplate = BOOST_TEMPLATE
		},
		other = {
			bigIceBlockTemplate = BIG_ICE_BLOCK_TEMPLATE,
		}
	},

	trackConfig = {
		distanceBetweenParallelLines = 3.35,
	},

	slotsOffsets = {
		powerup = Vector3.new(0, 4, 0),
		boost = Vector3.new(0, 0.5, 0),
		spikes = Vector3.new(0, 0.1, 0),
	},

	spawnCounts = {
		powerups = 7,
		boosts = 7,
		spikes = 7,
	},

	playerStats = {
		defaultSpeed = 12,

		boostDuration = 3, 
		boostedSpeed = 18,
		boostImpulse = Vector3.new(0, 1000, 1000) -- x -> right, y -> up, z -> forward
	}
}