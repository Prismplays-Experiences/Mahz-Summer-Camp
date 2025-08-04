local Players = game:GetService("Players")

local RaceInfo = require("@Info/Events/RaceInfo")
local Knit = require("@Packages/Knit")
local types = require("../../types")

type PowerupsUiController = types.PowerupsUiController

local player = Players.LocalPlayer

local PowerupsUiController = Knit.CreateController({
	Name = "PowerupsUiController",
})

function PowerupsUiController.KnitStart(self: PowerupsUiController)
	self:_setProperties()
end

function PowerupsUiController._setProperties(self: PowerupsUiController)
	self._powerupsFillerController = Knit.GetController("PowerupsFillerController")
	self._powerupsViewportController = Knit.GetController("PowerupsViewportController")
end

function PowerupsUiController.SetVisible(visible: boolean)
	RaceInfo.ui.powerupButton(player).Visible = visible
end

function PowerupsUiController.SetLastTimeUsed(self: PowerupsUiController, lastTimeUsed: number)
	self._powerupsFillerController:SetLastTimeUsed(lastTimeUsed)
end

function PowerupsUiController.CleanViewportInstance(self: PowerupsUiController)
	self._powerupsViewportController:CleanViewportInstance()
end

function PowerupsUiController.AddViewportInstance(self: PowerupsUiController, powerupName: string)
	self._powerupsViewportController:AddViewportInstance(powerupName)
end

function PowerupsUiController.GetViewportInstance(self: PowerupsUiController): Model | BasePart
	return self._powerupsViewportController:GetViewportInstance()
end

return PowerupsUiController
