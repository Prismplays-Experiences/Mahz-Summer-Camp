local Physics = require("@Modules/Utils/Physics")

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
local BIG_ICE_BLOCK_TEMPLATE: Model & {
	Meshessd_Cube: MeshPart & {
		WeldConstraint: WeldConstraint,
	},
} =
	RACE_MODELS_FOLDER:WaitForChild("BigIceBlock")
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

local function GET_BAR(player: Player): CanvasGroup & { Filler: Frame }
	local frame = GET_FRAME(player)
	local bar = frame:WaitForChild("Bar")

	return bar
end

local function GET_STATUS(player: Player): TextLabel
	local frame = GET_FRAME(player)
	local status = frame:WaitForChild("Status")

	return status
end

local function GET_FILLER(player: Player): Frame & { UIGradient: UIGradient }
	local powerupButton = GET_POWERUP_BUTTON(player)
	local filler = powerupButton:WaitForChild("Filler")

	return filler
end

local function GET_POWERUP_KEYCODE_LABEL(player: Player): TextLabel
	local powerupButton = GET_POWERUP_BUTTON(player)
	local keyCodeLabel = powerupButton:WaitForChild("KeyCode")

	return keyCodeLabel
end

local function CALCULATE_BOMB_IMPULSE(character: Model): Vector3
	local DEFAULT_MASS = 2560
	local DEFAULT_IMPULSE = Vector3.new(0, 14000, 0)

	local playerMass = Physics.GetMass(character)

	return DEFAULT_IMPULSE * (playerMass / DEFAULT_MASS)
end

local function CALCULATE_SPIKES_IMPULSE(): Vector3
	local function randomSign()
		return 2 ^ math.random(1, 2) - 3
	end

	local impulseX = randomSign() * math.random(3, 5) / 2
	local impulseZ = randomSign() * math.random(3, 5) / 2

	return Vector3.new(impulseX, 7.5, impulseZ)
end

return {
	instances = {
		track = {
			bordersFolder = BORDERS_FOLDER,
			finishLine = FINISH_LINE,
			landmarksFolder = LANDMARKS_FOLDER,
			polarPerpendicularAxis = POLAR_PERPENDICULAR_AXIS,
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
		},
	},

	trackConfig = {
		distanceBetweenParallelLines = 5,
		laps = 2,
		leaderboardsUpdateInterval = 1,
		checkpoints = { { 0, 0.24 }, { 0.24, 0.48 }, { 0.48, 0.72 }, { 0.72, 0.95 }, { 0.95, 1 } },
	},

	slotsOffsets = {
		powerup = Vector3.new(0, 4, 0),
		boost = Vector3.new(0, 0.5, 0),
		spikes = Vector3.new(0, 0.72, 0),
	},

	spawnCounts = {
		powerups = 20,
		boosts = 30,
		spikes = 20,
	},

	playerStats = {
		defaultSpeed = 0,
		boostedSpeed = 5,
		boostDuration = 2.5,
		boostImpulse = Vector3.new(0, 1, 8), -- x -> right, y -> up, z -> forward. Relative to humanoid root part's look vector
	},

	spikes = {
		impulse = CALCULATE_SPIKES_IMPULSE, -- relative to world space
		ragdollDuration = 3,
	},

	powerupGiver = {
		floatingAmplitude = 0.03,
		floatingSpeed = 2,
		rotationSpeed = 1,
	},

	powerups = {
		bomb = {
			impulse = CALCULATE_BOMB_IMPULSE, -- relative to world space
			ragdollDuration = 3,
			dropTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			dropStartHeight = 20,
		},
		iceBlock = {
			duration = 5,
		},
	},

	teleportation = {
		raceStartPosition = Vector3.new(-116.288, 6.777, 154.166),
		mapCenterPosition = Vector3.new(-103.269, 6.777, 19.281),
	},

	ui = {
		frame = GET_FRAME,
		powerupButton = GET_POWERUP_BUTTON,
		powerupFiller = GET_FILLER,
		bar = GET_BAR,
		status = GET_STATUS,
		powerupKeyCodeLabel = GET_POWERUP_KEYCODE_LABEL,

		statusText = "Race ends in %s seconds!",

		powerupButtonCameraPosition = Vector3.new(2, 2, 10),
		powerupButtonCameraFov = 30,
		powerupInstanceRotationSpeed = 1,

		cooldownSpringSpeed = 20,
		cooldownSpringDamping = 1,
	},

	eventProps = {
		title = "Track Event!",
		image = "rbxassetid://94937288830539", -- Replace with actual image ID
		lockWorkoutMachines = true,
		yieldClock = true,
		minPlayers = 1,
		duration = 10,

		firstPlaceWeightLoss = 25,
	},

	tapSpeed = {
		speedLosePerSecond = 1,
		speedPerTap = 0.3,
		maxSpeed = 9,
		startSpeed = 2.5,

		speedSpringDamping = 1,
		speedSpringSpeed = 5,
	},

	powerupsOverallInfo = {
		cooldown = 8,

		pcKeyCode = Enum.KeyCode.Q,
		consoleKeyCode = Enum.KeyCode.ButtonL1,
	},
}
