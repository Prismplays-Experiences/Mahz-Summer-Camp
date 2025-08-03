export type RaceUiController = {
	_powerupsController: PowerupsController,
	_raceUiService: {[any]: any},

	_setProperties: (self: RaceUiController) -> (),
	_connectEvents: (self: RaceUiController) -> (),

	Hide: (self: RaceUiController) -> (),
	Show: (self: RaceUiController) -> (),

	_setVisible: (self: RaceUiController, visible: boolean) -> (),
	_setRaceFrameVisible: (visible: boolean) -> (),
}

export type PowerupsController = {
	_powerupsService: {Use: (_: {[any]: any}) -> {
		await: (_: {[any]: any}) -> (boolean, boolean),
	}},
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
	GetPowerupsService: (self: PowerupsController) -> {Use: () -> {
		await: (_: {[any]: any}) -> (boolean, boolean),
	}},

	_getPowerupInstance: (self: PowerupsController) -> Part | Model?,
	_getViewportInstance: (self: PowerupsController) -> Part | Model?,
	_cleanViewport: (self: PowerupsController) -> (),
	_addToViewport: (self: PowerupsController, instance: Instance) -> (),
	_setPosition: (instance: Instance, position: Vector3) -> (),
	_setCframe: (instance: Instance, cframe: CFrame) -> (),
	_getCframe: (instance: Instance) -> CFrame,
	_rotatePowerup: (self: PowerupsController, angle: number) -> (),
}

return {}