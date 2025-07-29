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

	OccupyFreeSlots: (self: LandmarksService, callback: (slotCframe: CFrame) -> Instance, numberOfSlots: number?) -> (),
	GetFreeSlots: (self: LandmarksService) -> { LandmarkSlot },

	AddLandmark: (self: LandmarksService, landmark: Landmark) -> (),
	SetLandmarks: (self: LandmarksService, landmarks: { Landmark }) -> (),

	GetLandmark: (self: LandmarksService, landmarkIndex: number) -> Landmark?,
	GetAllLandmarks: (self: LandmarksService) -> { Landmark },
}

export type BoostsService = {
	SpawnAll: (self: BoostsService) -> (),
	_spawnOne: () -> (),
}

export type BordersService = {
	ChangeCollision: (state: boolean) -> (),
}

export type PowerupsService = {
	landmarksService: LandmarksService,

	SpawnAll: (self: PowerupsService) -> (),

	_spawnOne: () -> (),
}

export type RaceService = {
	bordersService: BordersService,
	powerupsService: PowerupsService,
	boostsService: BoostsService,

	Start: (self: RaceService) -> (),

	_changeBordersCollision: (state: boolean) -> (),
}

return {}