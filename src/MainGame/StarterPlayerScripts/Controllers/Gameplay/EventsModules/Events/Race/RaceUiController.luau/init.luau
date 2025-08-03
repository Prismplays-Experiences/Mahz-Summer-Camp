local Players = game:GetService("Players")

local RaceInfo = require("@Info/Events/RaceInfo")
local Knit = require("@Packages/Knit")
local types = require("./types")

type RaceUiController = types.RaceUiController

local player = Players.LocalPlayer

local RaceUiController = Knit.CreateController { Name = "RaceUiController" }

function RaceUiController.KnitInit(self: RaceUiController)
	self:_setProperties()
	self:_connectEvents()
end

function RaceUiController.Show(self: RaceUiController)
	self:_setVisible(true)
end

function RaceUiController.Hide(self: RaceUiController)
	self:_setVisible(false)
end

function RaceUiController._setProperties(self: RaceUiController)
	self._powerupsController = Knit.GetController("PowerupsController")
	self._raceTimeController = Knit.GetController("RaceTimeController")
	self._raceUiService = Knit.GetService("RaceUiService")
end

function RaceUiController._connectEvents(self: RaceUiController)
	self._raceUiService.Show:Connect(function()
		self:_setVisible(true)
	end)

	self._raceUiService.Hide:Connect(function()
		self:_setVisible(false)
	end)
end

function RaceUiController._setVisible(self: RaceUiController, visible: boolean)
	self._setRaceFrameVisible(visible)
	self._powerupsController:SetVisible(visible)
	self._raceTimeController:SetVisible(visible)
end

function RaceUiController._setRaceFrameVisible(visible: boolean)
	local raceFrame = RaceInfo.ui.frame(player)

	raceFrame.Visible = visible
end

return RaceUiController
