local Knit = require("@Packages/Knit")
local RaceInfo = require("@Info/Events/RaceInfo")
local types = require("./types")

local BORDERS_FOLDER = RaceInfo.instances.track.bordersFolder

type BordersService = types.BordersService

local BordersService = Knit.CreateService({
	Name = "BordersService",
	Client = {
		BordersChanged = Knit.CreateSignal("BordersChanged"),
	},
})

function BordersService.ChangeCollision(state: boolean)
	for _, border in ipairs(BORDERS_FOLDER:GetChildren()) do
		border.CanCollide = state
	end
end

return BordersService
