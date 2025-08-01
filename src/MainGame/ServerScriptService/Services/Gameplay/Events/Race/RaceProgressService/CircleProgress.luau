local Mathematics = require("@Modules/Utils/Mathematics")
local RaceInfo = require("@Info/Events/RaceInfo")

local POLAR_PERPENDICULAR_AXIS_INSTANCE = RaceInfo.instances.track.polarPerpendicularAxis
local MAX_ANGLE = 2 * math.pi

local CircleProgress = {}

function CircleProgress.Get(player: Player): number
	local angle = Mathematics.CalculateAngleBetweenPlayerAndPart(player, POLAR_PERPENDICULAR_AXIS_INSTANCE)
	local progress = angle / MAX_ANGLE

	return progress
end

return CircleProgress
