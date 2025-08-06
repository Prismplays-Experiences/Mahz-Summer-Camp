local Knit = require("@Packages/Knit")
local types = require("./types")

type RaceUiService = types.RaceUiService

local RaceUiService = Knit.CreateService({
	Name = "RaceUiService",
	Client = {
		Show = Knit.CreateSignal(),
		Hide = Knit.CreateSignal(),
	},
})

function RaceUiService.Show(self: RaceUiService)
	self.Client.Show:FireAll()
end

function RaceUiService.Hide(self: RaceUiService)
	self.Client.Hide:FireAll()
end

return RaceUiService
