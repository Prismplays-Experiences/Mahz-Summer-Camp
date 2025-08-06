local POWERUPS = require("@Modules/Events/Race/Powerups")

local PowerupModuleGetter = {}

function PowerupModuleGetter.Get(powerupName: string?): { [string]: any }
	return POWERUPS[powerupName]
end

return PowerupModuleGetter