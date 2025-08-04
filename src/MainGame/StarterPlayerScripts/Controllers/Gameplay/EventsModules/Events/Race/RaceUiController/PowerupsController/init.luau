local Knit = require("@Packages/Knit")

local types = require("../types")

type PowerupsController = types.PowerupsController

local PowerupsController = Knit.CreateController({ Name = "PowerupsController" })

function PowerupsController.KnitStart(self: PowerupsController)
	self:_setProperties()
	self:_connectEvents()
end

function PowerupsController._setProperties(self: PowerupsController)
	self._powerupsService = Knit.GetService("PowerupsService")
	self._powerupsUiController = Knit.GetController("PowerupsUiController")
	self._powerupsActivationController = Knit.GetController("PowerupsActivationController")
end

function PowerupsController._connectEvents(self: PowerupsController)
	self._powerupsActivationController.Activated:Connect(function()
		self:Use()
	end)

	self._powerupsService.LastTimeUsed:Observe(function(lastTimeUsed: number)
		self._powerupsUiController:SetLastTimeUsed(lastTimeUsed)
	end)

	self._powerupsService.PowerupReceived:Connect(function(powerupName: string)
		self:SetPowerup(powerupName)
	end)
end

function PowerupsController.SetVisible(self: PowerupsController, visible: boolean)
	self._powerupsUiController.SetVisible(visible)
end

function PowerupsController.Use(self: PowerupsController): boolean
	local service = self._powerupsService
	local _, success = service:Use():await()
	
	if success == true then
		self._powerupsUiController:CleanViewportInstance()
	end

	return success
end

function PowerupsController.SetPowerup(self: PowerupsController, powerupName: string)
	self._powerupsUiController:AddViewportInstance(powerupName)
end

return PowerupsController
