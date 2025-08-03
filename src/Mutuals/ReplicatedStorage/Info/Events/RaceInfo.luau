local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GAME_FOLDER = workspace:WaitForChild("Game")
local EVENTS_WORKSPACE_FOLDER = GAME_FOLDER:WaitForChild("ScriptingProperties"):WaitForChild("Events")
local RACE_WORKSPACE_FOLDER = EVENTS_WORKSPACE_FOLDER:WaitForChild("Track1800M")

local EVENTS_MODELS_FOLDER = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Events")
local RACE_MODELS_FOLDER = EVENTS_MODELS_FOLDER:WaitForChild("Race")

local BORDERS_FOLDER = RACE_WORKSPACE_FOLDER:WaitForChild("Borders")
local FINISH_LINE = RACE_WORKSPACE_FOLDER:WaitForChild("Finishline")
local LANDMARKS_FOLDER = RACE_WORKSPACE_FOLDER:WaitForChild("Landmarks")
local POLAR_PERPENDICULAR_AXIS = RACE_WORKSPACE_FOLDER:WaitForChild("PolarPerpendicularAxis")

local POWERUP_TEMPLATE = RACE_MODELS_FOLDER:WaitForChild("Powerup")

local BANANA_TEMPLATE = RACE_MODELS_FOLDER:WaitForChild("Banana")
local BOMB_TEMPLATE = RACE_MODELS_FOLDER:WaitForChild("bomb")
local SPIKES_TEMPLATE = RACE_MODELS_FOLDER:WaitForChild("Spikes")
local SMALL_ICE_BLOCK_TEMPLATE = RACE_MODELS_FOLDER:WaitForChild("SmallIceBlock")
local BIG_ICE_BLOCK_TEMPLATE = RACE_MODELS_FOLDER:WaitForChild("BigIceBlock")
local BOOST_TEMPLATE = RACE_MODELS_FOLDER:WaitForChild("Boost")

local SPAWNED_INSTANCES_FOLDER = Instance.new("Folder")
SPAWNED_INSTANCES_FOLDER.Parent = workspace

local function GET_FRAME(player: Player): Frame
	local playerGui = player:WaitForChild("PlayerGui")
	local mainUi = playerGui:WaitForChild("Main")
	local eventsUi = mainUi:WaitForChild("EventsInterfaces")
	local raceUi = eventsUi:WaitForChild("Track1800m")

	return raceUi
end

local function GET_POWERUP_BUTTON(player: Player): ImageButton
	local frame = GET_FRAME(player)
	local button = frame:WaitForChild("PowerupBox")

	return button
end

local function GET_BAR(player: Player): CanvasGroup
	local frame = GET_FRAME(player)
	local bar = frame:WaitForChild("Bar")

	return bar
end

return {
	instances = {
		track = {
			bordersFolder = BORDERS_FOLDER,
			finishLine = FINISH_LINE,
			landmarksFolder = LANDMARKS_FOLDER,
			polarPerpendicularAxis = POLAR_PERPENDICULAR_AXIS
		},
		powerups = {
			bananaTemplate = BANANA_TEMPLATE,
			bombTemplate = BOMB_TEMPLATE,
			smallIceBlockTemplate = SMALL_ICE_BLOCK_TEMPLATE,
		},
		spawnables = {
			powerupTemplate = POWERUP_TEMPLATE,
			spikesTemplate = SPIKES_TEMPLATE,
			boostTemplate = BOOST_TEMPLATE,
			spawnedInstancesFolder = SPAWNED_INSTANCES_FOLDER,
		},
		other = {
			bigIceBlockTemplate = BIG_ICE_BLOCK_TEMPLATE,
		}
	},

	trackConfig = {
		distanceBetweenParallelLines = 3.5, --3.35
		laps = 2,
		leaderboardsUpdateInterval = 1,
		checkpoints = {{0, 0.48}, {0.48, 0.95}, {0.95, 1}},
	},

	slotsOffsets = {
		powerup = Vector3.new(0, 4, 0),
		boost = Vector3.new(0, 0.5, 0),
		spikes = Vector3.new(0, 0.72, 0),
	},

	spawnCounts = {
		powerups = 20,
		boosts = 30,
		spikes = 0,
	},

	playerStats = {
		defaultSpeed = 20,

		boostDuration = 2.5,
		boostedSpeed = 25,
		boostImpulse = Vector3.new(0, 1, 12), -- x -> right, y -> up, z -> forward. Relative to humanoid root part's look vector
	},

	spikes = {
		impulse = Vector3.new(0, 1000, 0), -- relative to world space
		ragdollDuration = 3,
	},

	powerupGiver = {
		floatingAmplitude = 0.03,
		floatingSpeed = 2,
		rotationSpeed = 1,
	},

	powerups = {
		bomb = {
			impulse = Vector3.new(0, 1000, 0), -- relative to world space
			ragdollDuration = 3,
			dropTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			dropStartHeight = 20
		},
		iceBlock = {
			duration = 5, 
		}
	},
	
	teleportation = {
		raceStartPosition = Vector3.new(-107.9, 6.438, 124.05),
		mapCenterPosition = Vector3.new(-103.269, 6.675, 19.281),
	},

	ui = {
		frame = GET_FRAME,
		powerupButton = GET_POWERUP_BUTTON,
		bar = GET_BAR,
		
		powerupButtonCameraPosition = Vector3.new(2, 2, 10),
		powerupButtonCameraFov = 30,
		powerupInstanceRotationSpeed = 1,
	}
}