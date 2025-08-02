local RaceInfo = require("@Info/Events/RaceInfo")
local Knit = require("@Packages/Knit")
local TableUtil = require("@Packages/TableUtil")

local RandomPowerup = {}

function RandomPowerup.Give(player: Player)
	local powerupsService = Knit.GetService("PowerupsService")

	local powerups = TableUtil.Keys(RaceInfo.powerups)
	local randomPowerup = powerups[math.random(#powerups)]

	powerupsService:Give(player, randomPowerup)
	
	return randomPowerup
end

return RandomPowerup