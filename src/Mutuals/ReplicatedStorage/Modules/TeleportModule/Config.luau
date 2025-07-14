local RunService = game:GetService("RunService")
local GeneralInfo = require(game.ReplicatedStorage.Info.GeneralInfo)

return {
	MinPlayers = RunService:IsStudio() and 1 or 1, --6,
	MaxPlayers = RunService:IsStudio() and 2 or 6, --12,

	tp_delay = 15, -- in seconds

	target_id = GeneralInfo.MainPlaceId, -- place id to get teleported to
}
