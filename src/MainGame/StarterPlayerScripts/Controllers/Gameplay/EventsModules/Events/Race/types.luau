local Fusion = require("@Packages/Fusion")
local Signal = require("@Packages/Signal")
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
	_powerupsService: {
		Use: (_: { [any]: any }) -> {
			await: (_: { [any]: any }) -> (boolean, boolean),
		},
		PowerupReceived: Signal.Signal<string>,
		LastTimeUsed: RemoteProperty<number>,
	},
	_powerupsUiController: PowerupsUiController,
	_powerupsActivationController: PowerupsActivationController,

	SetVisible: (self: PowerupsController, visible: boolean) -> (),
	Use: (self: PowerupsController) -> boolean,
	SetPowerup: (self: PowerupsController, powerupName: string) -> (),

	_setProperties: (self: PowerupsController) -> (),
	_connectEvents: (self: PowerupsController) -> (),
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
	Hydrate: (any, any) -> ({ Size: Fusion.Computed<UDim2> }) -> any,
}>

export type RaceTapUiController = {
	_scope: RaceTapUiScope,
	_bar: Bar,

	SetVisible: (self: RaceTapUiController, visible: boolean) -> (),
	ConnectToSpeed: (self: RaceTapUiController, speed: Fusion.Spring<number>) -> (),

	_getBar: (self: RaceTapUiController) -> Bar,
	_getScope: (self: RaceTapUiController) -> RaceTapUiScope,
}

export type PowerupsActivationController = {
	_powerupButton: ImageButton,

	Activated: Signal.Signal<>,

	_getPowerupButton: (self: PowerupsActivationController) -> ImageButton,
	_setProperties: (self: PowerupsActivationController) -> (),
	_connectEvents: (self: PowerupsActivationController) -> (),
	_createSignals: (self: PowerupsActivationController) -> (),
}

export type PowerupsUiController = {
	_powerupsViewportController: PowerupsViewportController,
	_powerupsFillerController: PowerupsFillerController,

	SetVisible: (visible: boolean) -> (),
	CleanViewportInstance: (self: PowerupsUiController) -> (),
	AddViewportInstance: (self: PowerupsUiController, powerupName: string) -> (),
	GetViewportInstance: (self: PowerupsUiController) -> ViewportInstance,
	SetLastTimeUsed: (self: PowerupsUiController, lastTimeUsed: number) -> (),

	_setProperties: (self: PowerupsUiController) -> (),
}

type ViewportInstance = BasePart | Model

export type PowerupsViewportController = {
	_viewportFrame: ViewportFrame,
	_viewportInstance: ViewportInstance,

	CleanViewportInstance: (self: PowerupsViewportController) -> (),
	AddViewportInstance: (self: PowerupsViewportController, powerupName: string) -> (),
	GetViewportInstance: (self: PowerupsViewportController) -> ViewportInstance,

	_setProperties: (self: PowerupsViewportController) -> (),
	_connectEvents: (self: PowerupsViewportController) -> (),
	_insertViewportInstance: (self: PowerupsViewportController, instance: ViewportInstance) -> (),
	_setViewportInstance: (self: PowerupsViewportController, instance: ViewportInstance) -> (),
	_rotateViewportInstance: (self: PowerupsViewportController, angle: number) -> (),
	_getPowerupInstance: (powerupName: string) -> ViewportInstance,
	_getViewportFrame: (self: PowerupsViewportController) -> ViewportFrame,
}

type PowerupsFillerScope = Fusion.Scope<{
	Value: (any, number) -> Fusion.Value<number>,
	Computed: (any, (Fusion.Use, any) -> number) -> Fusion.Computed<number>,
	Hydrate: (any, any) -> ({ Size: Fusion.Computed<UDim2> }) -> any,
	Spring: (any, Fusion.Value<number>, number, number) -> Fusion.Spring<number>,
}>

export type PowerupsFillerController = {
	_filler: Frame & { UIGradient: UIGradient },
	_lastTimeUsed: Fusion.Value<number>,
	_scope: PowerupsFillerScope,

	SetLastTimeUsed: (self: PowerupsFillerController, lastTimeUsed: number) -> (),

	_setProperties: (self: PowerupsFillerController) -> (),
	_hydrateFiller: (self: PowerupsFillerController) -> (),
	_getFiller: (self: PowerupsFillerController) -> Frame & { UIGradient: UIGradient },
	_getScope: (self: PowerupsFillerController) -> PowerupsFillerScope,
	_getLastTimeUsed: (self: PowerupsFillerController) -> Fusion.Value<number>,
}

export type PowerupsKeyUiController = {}

return {}
