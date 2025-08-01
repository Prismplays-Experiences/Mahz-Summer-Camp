local Booker = require("@CustomModules/Booker")

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
		[number]: LandmarkSlot
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
		[number]: Landmark
	},

	OccupyFreeSlots: (self: LandmarksService, callback: (slotCframe: CFrame) -> Instance, numberOfSlots: number?) -> { LandmarkSlot },
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
		[number]: LandmarkSlot
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
	laps: number
}

export type LapsProgress = {
	_laps: { [Player]: number },

	GetPlayerProgress: (self: LapsProgress, player: Player) -> number,

	IncrementLap: (self: LapsProgress, player: Player) -> (),
	GetPlayerLaps: (self: LapsProgress, player: Player) -> number,
	GetEveryoneLaps: (self: LapsProgress) -> { [Player]: number },

	GetMaxLaps: () -> number,
}

export type ProgressCompiler = {
	IncrementLap: (self: ProgressCompiler, player: Player) -> (),

	GetEveryoneLaps: (self: ProgressCompiler) -> { [Player]: number },
	GetPlayerLaps: (self: ProgressCompiler, player: Player) -> number,

	GetProgresses: (self: ProgressCompiler) -> { [Player]: ProgressTable },
	GetProgressForPlayer: (self: ProgressCompiler, player: Player) -> ProgressTable,

	_lapsProgress: LapsProgress,
}

export type ProgressTypes = "total" | "circle" | "laps"

export type RaceProgressService = {
	_progressCompiler: ProgressCompiler?,

	Start: (self: RaceProgressService) -> (),
	Stop: (self: RaceProgressService) -> (),

	IncrementLap: (self: RaceProgressService, player: Player) -> (),

	GetNearestPlayer: (self: RaceProgressService, player: Player) -> Player?,
	GetRelativePlayerInfo: (self: RaceProgressService, player: Player, deltaIndex: number, excludeLaps: boolean?) -> {player: Player, progress: number}?,

	GetLeaderboard: (self: RaceProgressService, excludeLaps: boolean?) -> { [number]: {player: Player, progress: number} },

	GetProgresses: (self: RaceProgressService) -> { [Player]: ProgressTable },
	GetPlayerProgress: (self: RaceProgressService, player: Player) -> ProgressTable,

	GetEveryoneLaps: (self: RaceProgressService) -> { [Player]: number },
	GetPlayerLaps: (self: RaceProgressService, player: Player) -> number
}

export type RaceMembersService = {
	raceMembersStoreService: RaceMembersStoreService,
	teleportationService: Service,

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

export type RaceService = {
	bordersService: BordersService,
	powerupsService: SlotSpawnerService<MeshPart>,
	boostsService: SlotSpawnerService<Part>,
	spikesService: SlotSpawnerService<Model>,
	raceProgressService: RaceProgressService,
	raceMembersService: RaceMembersService,

	Start: (self: RaceService) -> (),

	_changeBordersCollision: (state: boolean) -> (),
}

return {}