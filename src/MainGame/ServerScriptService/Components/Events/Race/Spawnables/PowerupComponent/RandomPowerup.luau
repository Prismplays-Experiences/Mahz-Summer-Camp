local RaceInfo = require("@Info/Events/RaceInfo")
local Knit = require("@Packages/Knit")
local TableUtil = require("@Packages/TableUtil")

local RandomPowerup = {}

function RandomPowerup.Give(player: Player): (boolean, string?)
	local powerupsService = Knit.GetService("PowerupsService")

	local powerups = TableUtil.Keys(RaceInfo.powerups)
	local randomPowerup = powerups[math.random(#powerups)]

	local isReceived = powerupsService:Give(player, randomPowerup)

	return isReceived, isReceived and randomPowerup or nil
end

return RandomPowerup