local Players = game:GetService("Players")

local RaceInfo = require("@Info/Events/RaceInfo")
local Fusion = require("@Packages/Fusion")
local Knit = require("@Packages/Knit")
local types = require("../../types")

local player = Players.LocalPlayer

local BAR = RaceInfo.ui.bar(player)
local MAX_SPEED = RaceInfo.tapSpeed.maxSpeed

type RaceTapUiController = types.RaceTapUiController
type Bar = types.Bar
type RaceTapUiScope = types.RaceTapUiScope

local RaceTapUiController = Knit.CreateController({ Name = "RaceTapUiController" })

function RaceTapUiController.KnitInit(self: RaceTapUiController)
	self._bar = BAR
	self._scope = Fusion.scoped({
		Computed = Fusion.Computed,
		Hydrate = Fusion.Hydrate,
	})
end

function RaceTapUiController.SetVisible(self: RaceTapUiController, visible: boolean): ()
	local bar = self._bar
	bar.Visible = visible
end

function RaceTapUiController.ConnectToSpeed(self: RaceTapUiController, speedSpring: Fusion.Spring<number>): ()
	local bar = self:_getBar()
	local scope = self:_getScope()

	local speedComputed = scope:Computed(function(use)
		local currentSpeed = use(speedSpring)
		local alpha = currentSpeed / MAX_SPEED

		return UDim2.fromScale(alpha, 1)
	end)

	scope:Hydrate(bar.Filler)({
		Size = speedComputed,
	})
end

function RaceTapUiController._getBar(self: RaceTapUiController): Bar
	return self._bar
end

function RaceTapUiController._getScope(self: RaceTapUiController): RaceTapUiScope
	return self._scope
end

return RaceTapUiController
