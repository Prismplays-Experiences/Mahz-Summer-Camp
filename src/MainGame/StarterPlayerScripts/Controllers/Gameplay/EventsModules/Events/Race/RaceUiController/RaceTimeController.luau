local Players = game:GetService("Players")

local RaceInfo = require("@Info/Events/RaceInfo")
local Knit = require("@Packages/Knit")
local types = require("../types")

type RaceTimeController = types.RaceTimeController

local player = Players.LocalPlayer

local RaceTimeController = Knit.CreateController { Name = "RaceTimeController" }

function RaceTimeController.KnitInit(self: RaceTimeController)
	self._timeService = Knit.GetService("RaceTimeService")
	self._timeLabel = RaceInfo.ui.status(player)
	
	self._timeService.Time:Observe(function(time: number)
		local timeLabel = self:_getTimeLabel()

		timeLabel.Text = RaceInfo.ui.statusText:format(time)
	end)
end

function RaceTimeController.SetVisible(self: RaceTimeController, visible: boolean)
	local timeLabel = self:_getTimeLabel()
	timeLabel.Visible = visible
end

function RaceTimeController._getTimeLabel(self: RaceTimeController): TextLabel
	return self._timeLabel
end

return RaceTimeController
