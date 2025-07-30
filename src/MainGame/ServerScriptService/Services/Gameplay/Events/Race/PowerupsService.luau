local Knit = require("@Packages/Knit")

export type PowerupsService = {
	-- Define any methods or properties that the PowerupsService will have
}

local PowerupsService = Knit.CreateService({
	Name = "PowerupsService",
	Client = {},
})

function PowerupsService.KnitInit()
	-- Initialize any properties or state here
end

return PowerupsService