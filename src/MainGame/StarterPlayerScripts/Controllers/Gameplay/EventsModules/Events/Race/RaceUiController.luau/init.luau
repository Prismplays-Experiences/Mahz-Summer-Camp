local Knit = require("@Packages/Knit")
local types = require("./types")

type RaceUiController = types.RaceUiController

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
end

function RaceUiController._setVisible(self: RaceUiController, visible: boolean)
	self._powerupsController:SetVisible(visible)
end

return RaceUiController
