local Fusion = require("@Packages/Fusion")
local Trove = require("@Packages/Trove")

export type RemoteProperty<T...> = {
	Observe: (self: RemoteProperty<T...>, callback: (T...) -> ()) -> (),
}

export type RaceUiController = {
	_powerupsController: PowerupsController,
	_raceTimeController: RaceTimeController,
	_raceTapController: RaceTapController,
	_raceFrame: Frame,
	_raceUiService: { [any]: any },

	_setProperties: (self: RaceUiController) -> (),
	_connectEvents: (self: RaceUiController) -> (),

	Hide: (self: RaceUiController) -> (),
	Show: (self: RaceUiController) -> (),

	_setVisible: (self: RaceUiController, visible: boolean) -> (),
	_setRaceFrameVisible: (visible: boolean) -> (),
}

export type RaceTimeController = {
	_timeService: { Time: RemoteProperty<number> },
	_timeLabel: TextLabel,

	SetVisible: (self: RaceTimeController, visible: boolean) -> (),

	_getTimeLabel: (self: RaceTimeController) -> TextLabel,
}

export type PowerupsController = {
	_powerupsService: { Use: (_: { [any]: any }) -> {
		await: (_: { [any]: any }) -> (boolean, boolean),
	} },
	_powerupBox: ImageButton,
	_powerup: string?,

	_setProperties: (self: PowerupsController) -> (),
	_connectEvents: (self: PowerupsController) -> (),

	SetVisible: (self: PowerupsController, visible: boolean) -> (),
	Use: (self: PowerupsController) -> boolean,
	UpdatePowerupBox: (self: PowerupsController) -> (),
	SetPowerup: (self: PowerupsController, powerupName: string) -> (),
	GetPowerup: (self: PowerupsController) -> string?,
	GetPowerupBox: (self: PowerupsController) -> ImageButton,
	GetPowerupsService: (
		self: PowerupsController
	) -> { Use: () -> {
		await: (_: { [any]: any }) -> (boolean, boolean),
	} },

	_getPowerupInstance: (self: PowerupsController) -> Part | Model?,
	_getViewportInstance: (self: PowerupsController) -> Part | Model?,
	_cleanViewport: (self: PowerupsController) -> (),
	_addToViewport: (self: PowerupsController, instance: Instance) -> (),
	_setPosition: (instance: Instance, position: Vector3) -> (),
	_setCframe: (instance: Instance, cframe: CFrame) -> (),
	_getCframe: (instance: Instance) -> CFrame,
	_rotatePowerup: (self: PowerupsController, angle: number) -> (),
}

export type RaceTapController = {
	_raceTapSpeedController: RaceTapSpeedController,
	_raceTapUiController: RaceTapUiController,
	_raceTapService: { SetSpeed: (any, speed: number) -> () },

	SetVisible: (self: RaceTapController, visible: boolean) -> (),

	Start: (self: RaceTapController) -> (),
	Stop: (self: RaceTapController) -> (),
}

export type RaceTapSpeedController = {
	_speed: Fusion.Value<number>,
	_speedSpring: Fusion.Spring<number>,
	_speedSpringObserver: Fusion.Observer,
	_trove: Trove.Trove,
	_scope: Fusion.Scope<{
		Value: (any, number) -> Fusion.Value<number>,
		Spring: (any, Fusion.Value<number>, number, number) -> Fusion.Spring<number>,
		Observer: (any, Fusion.Spring<number>) -> Fusion.Observer,
	}>,

	Start: (self: RaceTapSpeedController) -> (),
	Stop: (self: RaceTapSpeedController) -> (),
	Observe: (self: RaceTapSpeedController, callback: (number) -> ()) -> (),
	GetSpeed: (self: RaceTapSpeedController) -> Fusion.Value<number>,
	GetSpeedSpring: (self: RaceTapSpeedController) -> Fusion.Spring<Fusion.Value<number>>,

	_setProperties: (self: RaceTapSpeedController) -> (),
	_connectEvents: (self: RaceTapSpeedController) -> (),
	_getObserver: (self: RaceTapSpeedController) -> Fusion.Observer,
	_cleanTrove: (self: RaceTapSpeedController) -> (),
	_getTrove: (self: RaceTapSpeedController) -> Trove.Trove,
	_addSpeed: (self: RaceTapSpeedController, additionalSpeed: number) -> (),
	_setSpeed: (self: RaceTapSpeedController, speed: number) -> (),
}

export type Bar = CanvasGroup & {
	Filler: Frame,
}

export type RaceTapUiScope = Fusion.Scope<{
	Computed: (any, (Fusion.Use, any) -> number) -> Fusion.Computed<number>,
	Hydrate: (any, any) -> (({Size: Fusion.Computed<UDim2>}) -> any),
}>

export type RaceTapUiController = {
	_scope: RaceTapUiScope,
	_bar: Bar,

	SetVisible: (self: RaceTapUiController, visible: boolean) -> (),
	ConnectToSpeed: (self: RaceTapUiController, speed: Fusion.Spring<number>) -> (),

	_getBar: (self: RaceTapUiController) -> Bar,
	_getScope: (self: RaceTapUiController) -> RaceTapUiScope
}

return {}
