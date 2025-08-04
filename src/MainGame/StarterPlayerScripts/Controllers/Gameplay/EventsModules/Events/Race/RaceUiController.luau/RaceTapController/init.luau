local Knit = require("@Packages/Knit")
local types = require("../types")

type RaceTapController = types.RaceTapController

local RaceTapController = Knit.CreateController { Name = "RaceTapController" }

function RaceTapController.KnitStart(self: RaceTapController)
	self._raceTapSpeedController = Knit.GetController("RaceTapSpeedController")
	self._raceTapUiController = Knit.GetController("RaceTapUiController")
	self._raceTapService = Knit.GetService("RaceTapService")

	local speedSpring = self._raceTapSpeedController:GetSpeedSpring()

	self._raceTapUiController:ConnectToSpeed(speedSpring)
end

function RaceTapController.SetVisible(self: RaceTapController, visible: boolean): ()
	self._raceTapUiController:SetVisible(visible)
end

function RaceTapController.Start(self: RaceTapController): ()
	self._raceTapSpeedController:Start()

	self._raceTapSpeedController:Observe(function(speed)
		self._raceTapService:SetSpeed(speed)
	end)
end

function RaceTapController.Stop(self: RaceTapController): ()
	self._raceTapSpeedController:Stop()
end

return RaceTapController
