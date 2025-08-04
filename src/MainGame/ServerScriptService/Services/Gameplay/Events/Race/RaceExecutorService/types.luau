local Booker = require("@CustomModules/Booker")
local Signal = require("@Packages/Signal")
local Trove = require("@Packages/Trove")

export type RemoteComm<T...> = {
	FireAll: (self: RemoteComm<T...>, T...) -> (),
	Fire: (self: RemoteComm<T...>, player: Player, T...) -> (),
	Connect: (self: RemoteComm<T...>, (player: Player, T...) -> ()) -> (),
}

export type RemoteProperty<T...> = {
	Set: (self: RemoteProperty<T...>, T...) -> (),
	SetFor: (self: RemoteProperty<T...>, player: Player, T...) -> (),
	Get: (self: RemoteProperty<T...>) -> T...,
	GetFor: (self: RemoteProperty<T...>, player: Player) -> T...,
}

export type Client<T> = {
	Server: T,
}

export type Service = {
	Name: string,
	Client: { [string]: any },

	[any]: any,
}

export type LandmarkSlot = {
	claimed: boolean,
	cframe: CFrame,
	instance: Part | Model | nil,

	Occupy: (self: LandmarkSlot, instance: Part | Model | nil) -> (),
	IsFree: (self: LandmarkSlot) -> boolean,
	Clear: (self: LandmarkSlot, destroyInstance: boolean?) -> (),
}

export type Landmark = {
	origin: CFrame,
	slots: {
		[number]: LandmarkSlot,
	},

	GetFreeSlots: (self: Landmark) -> { LandmarkSlot },
	GetFreeSlotIndex: (self: Landmark) -> number?,
	IsSlotFree: (self: Landmark, slotIndex: number) -> boolean,

	OccupySlot: (self: Landmark, slotIndex: number, instance: Instance) -> (),

	ClearAllSlots: (self: Landmark, destroyInstances: boolean?) -> (),
	ClearSlot: (self: Landmark, slotIndex: number, destroyInstance: boolean?) -> (),
}

export type LandmarksService = {
	landmarks: {
		[number]: Landmark,
	},

	OccupyFreeSlots: (
		self: LandmarksService,
		callback: (slotCframe: CFrame) -> Instance,
		numberOfSlots: number?
	) -> { LandmarkSlot },
	GetFreeSlots: (self: LandmarksService) -> { LandmarkSlot },

	AddLandmark: (self: LandmarksService, landmark: Landmark) -> (),
	SetLandmarks: (self: LandmarksService, landmarks: { Landmark }) -> (),

	GetLandmark: (self: LandmarksService, landmarkIndex: number) -> Landmark?,
	GetAllLandmarks: (self: LandmarksService) -> { Landmark },
}

export type BordersService = {
	ChangeCollision: (state: boolean) -> (),
}

export type SlotSpawnerService<T> = {
	slots: {
		[number]: LandmarkSlot,
	},
	landmarksService: LandmarksService,
	template: Booker.Booker<T>,

	Spawn: (self: SlotSpawnerService<T>, slotsCount: number?) -> (),
	Clean: (self: SlotSpawnerService<T>, slotsCount: number?) -> (),

	SetSlots: (self: SlotSpawnerService<T>, slots: { LandmarkSlot }) -> (),
	GetSlots: (self: SlotSpawnerService<T>) -> { LandmarkSlot },
}

export type ProgressTable = {
	total: number,
	circle: number,
	laps: number,
}

export type LapsProgress = {
	_laps: { [Player]: number },

	GetPlayerProgress: (self: LapsProgress, player: Player) -> number,

	IncrementLap: (self: LapsProgress, player: Player, quantity: number?) -> (),
	GetPlayerLaps: (self: LapsProgress, player: Player) -> number,
	GetEveryoneLaps: (self: LapsProgress) -> { [Player]: number },

	GetMaxLaps: () -> number,
}

export type ProgressCompiler = {
	IncrementLap: (self: ProgressCompiler, player: Player, quantity: number?) -> (),

	GetEveryoneLaps: (self: ProgressCompiler) -> { [Player]: number },
	GetPlayerLaps: (self: ProgressCompiler, player: Player) -> number,

	GetProgresses: (self: ProgressCompiler) -> { [Player]: ProgressTable },
	GetProgressForPlayer: (self: ProgressCompiler, player: Player) -> ProgressTable,

	_lapsProgress: LapsProgress,
}

export type ProgressTypes = "total" | "circle" | "laps"

export type CheckpointsService = {
	_checkpoints: { [Player]: number },

	UpdateCheckpoints: (self: CheckpointsService, progresses: { [Player]: number }) -> { Player },
	GetNextCheckpoints: (self: CheckpointsService) -> { [Player]: number },
}

export type RaceProgressService = {
	_progressCompiler: ProgressCompiler?,
	_observePlayersConnection: RBXScriptConnection?,
	_checkpointsService: CheckpointsService,
	_raceMembersService: RaceMembersService,

	Start: (self: RaceProgressService) -> (),
	Stop: (self: RaceProgressService) -> (),

	IncrementLap: (self: RaceProgressService, player: Player, quantity: number?) -> (),

	GetNearestPlayer: (self: RaceProgressService, player: Player) -> Player?,
	GetRelativePlayerInfo: (
		self: RaceProgressService,
		player: Player,
		deltaIndex: number,
		excludeLaps: boolean?
	) -> { player: Player, progress: number }?,

	GetLeaderboard: (
		self: RaceProgressService,
		excludeLaps: boolean?
	) -> { [number]: { player: Player, progress: number } },

	GetProgresses: (self: RaceProgressService) -> { [Player]: ProgressTable },
	GetPlayerProgress: (self: RaceProgressService, player: Player) -> ProgressTable,

	GetEveryoneLaps: (self: RaceProgressService) -> { [Player]: number },
	GetPlayerLaps: (self: RaceProgressService, player: Player) -> number,
}

export type RaceMembersService = {
	raceMembersStoreService: RaceMembersStoreService,
	teleportationService: Service,
	raceSpeedService: RaceSpeedService,

	AddAllPlayers: (self: RaceMembersService) -> (),
	RemoveAllPlayers: (self: RaceMembersService) -> (),

	AddPlayer: (self: RaceMembersService, player: Player) -> (),
	RemovePlayer: (self: RaceMembersService, player: Player) -> (),

	IsPlayerInRace: (self: RaceMembersService, player: Player) -> boolean,
	GetPlayers: (self: RaceMembersService) -> { [Player]: boolean },
}

export type RaceMembersStoreService = {
	_players: { [number]: Player },

	AddPlayer: (self: RaceMembersStoreService, player: Player) -> (),
	RemovePlayer: (self: RaceMembersStoreService, player: Player) -> (),

	IsPlayerInRace: (self: RaceMembersStoreService, player: Player) -> boolean,
	GetPlayers: (self: RaceMembersStoreService) -> { [Player]: boolean },
}

export type RaceSpeedService = {
	_raceTapService: RaceTapService,
	_raceSpeedStateService: RaceSpeedStateService,
	_trove: Trove.Trove,

	StartForEveryone: (self: RaceSpeedService, players: {Player}) -> (),
	Start: (self: RaceSpeedService, player: Player) -> (),
	Stop: (self: RaceSpeedService) -> (),
	GetPlayerSpeed: (self: RaceSpeedService, player: Player) -> number,
	CreateStateMachineForPlayer: (self: RaceSpeedService, player: Player) -> (),

	_setProperties: (self: RaceSpeedService) -> (),
	_connectEvents: (self: RaceSpeedService, player: Player) -> (),
	_cleanTrove: (self: RaceSpeedService) -> (),
	_getTrove: (self: RaceSpeedService) -> Trove.Trove,
}

export type RaceTapService = {
	_playersSpeed: { [Player]: number },

	Client: {
		SetSpeed: (Client<RaceTapService>, player: Player, speed: number) -> (),
	},

	SetSpeed: (self: RaceTapService, player: Player, speed: number) -> (),
	GetSpeed: (self: RaceTapService, player: Player) -> number,
	GetAllPlayersSpeed: (self: RaceTapService) -> { [Player]: number },

	_setProperties: (self: RaceTapService) -> (),
}

export type RaceSpeedStateService = {
	_playersSpeed: { [Player]: number },
	_playersStates: { [Player]: { [any]: any } },

	CreateStateMachineForPlayer: (self: RaceSpeedStateService, player: Player) -> (),
	BoostPlayer: (self: RaceSpeedStateService, player: Player) -> (),
	StartStateMachines: (self: RaceSpeedStateService) -> (),
	StopStateMachines: (self: RaceSpeedStateService) -> (),
	GetSpeed: (self: RaceSpeedStateService, player: Player) -> number,

	_getPlayerStateMachine: (self: RaceSpeedStateService, player: Player) -> { [any]: any }?,
	_getAllPlayersStateMachines: (self: RaceSpeedStateService) -> { [Player]: { [any]: any } },
	_enterBoostMode: (self: RaceSpeedStateService, player: Player) -> (),
	_enterDefaultMode: (self: RaceSpeedStateService, player: Player) -> (),
	_setPlayerSpeed: (self: RaceSpeedStateService, player: Player, speed: number) -> (),
	_getPlayersSpeed: (self: RaceSpeedStateService) -> number,
}

export type PowerupsService = {
	_powerups: { [Player]: string },
	_raceProgressService: RaceProgressService,

	Client: {
		Use: (self: Client<PowerupsService>, player: Player) -> boolean,
		PowerupReceived: Signal.Signal<Player, string>,
		LastTimeUsed: RemoteProperty<number>,
	},

	Use: (self: PowerupsService, player: Player) -> boolean,
	Give: (self: PowerupsService, player: Player, powerupName: string) -> boolean,

	GetPowerup: (self: PowerupsService, player: Player) -> string?,
	GetAllPowerups: (self: PowerupsService) -> { [Player]: string },

	_activatePowerup: (self: PowerupsService, player: Player) -> boolean,
	_setPowerup: (self: PowerupsService, player: Player, powerupName: string?) -> (),
	_canPlayerUsePowerup: (self: PowerupsService, player: Player) -> boolean,
	_getLastTimeUsed: (self: PowerupsService, player: Player) -> number,
	_updateLastTimeUsed: (self: PowerupsService, player: Player) -> (),
}

export type RaceUiService = {
	Client: {
		Show: RemoteComm<>,
		Hide: RemoteComm<>,
	},

	Hide: (self: RaceUiService) -> (),
	Show: (self: RaceUiService) -> (),
}

export type RaceTimeService = {
	_time: number,

	Client: {
		Time: RemoteProperty<number>,
	},

	GetTime: (self: RaceTimeService) -> number,
	Start: (self: RaceTimeService) -> (),

	_setTime: (self: RaceTimeService, time: number) -> (),
	_decreaseTime: (self: RaceTimeService) -> (),
}

export type RaceRewardsService = {
	_raceProgressService: RaceProgressService,

	GiveRewards: (self: RaceRewardsService) -> (),

	_calculateWeightLoss: (playerPlace: number, playersQuantity: number) -> number,
	_calculateLifesLoss: (playerPlace: number, playersQuantity: number) -> number,

	_getLeaders: (self: RaceRewardsService) -> {
		{
			player: Player,
			progress: number,
		}
	},

	_giveWeightLoss: (player: Player, weightLoss: number) -> (),
	_giveLifesLoss: (player: Player, lifesLoss: number) -> (),
}

export type RaceExecutorService = {
	bordersService: BordersService,
	powerupsService: SlotSpawnerService<MeshPart>,
	boostsService: SlotSpawnerService<Part>,
	spikesService: SlotSpawnerService<Model>,
	raceProgressService: RaceProgressService,
	raceMembersService: RaceMembersService,
	raceUiService: RaceUiService,
	raceTimeService: RaceTimeService,
	raceRewardsService: RaceRewardsService,

	Start: (self: RaceExecutorService) -> (),
	Clean: (self: RaceExecutorService) -> (),

	_changeBordersCollision: (state: boolean) -> (),
}

export type RaceService = {
	_raceExecutorService: RaceExecutorService,

	MinPlayers: number,
	LockWorkoutMachines: boolean,
	YieldClock: boolean,
	Ended: Signal.Signal<>,
	Details: { Text: string, Image: string },

	Start: (self: RaceService) -> (),
}

return {}
