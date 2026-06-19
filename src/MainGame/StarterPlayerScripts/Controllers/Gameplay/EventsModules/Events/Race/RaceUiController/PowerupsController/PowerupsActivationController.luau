local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Knit = require("@Packages/Knit")
local RaceInfo = require("@Info/Events/RaceInfo")
local Signal = require("@Packages/Signal")
local types = require("../../types")

type PowerupsActivationController = types.PowerupsActivationController

local player = Players.LocalPlayer

local POWERUP_BUTTON = RaceInfo.ui.powerupButton(player)
local PC_KEYCODE = RaceInfo.powerupsOverallInfo.pcKeyCode
local CONSOLE_KEYCODE = RaceInfo.powerupsOverallInfo.consoleKeyCode

local PowerupsActivationController = Knit.CreateController({
	Name = "PowerupsActivationController",
})

function PowerupsActivationController.KnitInit(self: PowerupsActivationController)
	self:_setProperties()
	self:_createSignals()
	self:_connectEvents()
end

function PowerupsActivationController._setProperties(self: PowerupsActivationController)
	self._powerupButton = POWERUP_BUTTON
end

function PowerupsActivationController._connectEvents(self: PowerupsActivationController)
	local powerupButton = self:_getPowerupButton()

	powerupButton.MouseButton1Click:Connect(function()
		self.Activated:Fire()
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if input.KeyCode == PC_KEYCODE or input.KeyCode == CONSOLE_KEYCODE then
			if powerupButton.Visible then
				self.Activated:Fire()
			end
		end
	end)
end

function PowerupsActivationController._createSignals(self: PowerupsActivationController)
	self.Activated = Signal.new()
end

function PowerupsActivationController._getPowerupButton(self: PowerupsActivationController): ImageButton
	return self._powerupButton
end

return PowerupsActivationController
