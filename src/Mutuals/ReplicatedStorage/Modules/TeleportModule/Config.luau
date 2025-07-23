local RunService = game:GetService("RunService")
local ExperienceInfo = require("@Info/ExperienceInfo")

return {
	MinPlayers = RunService:IsStudio() and 1 or 1, --6,
	MaxPlayers = RunService:IsStudio() and 2 or 6, --12,

	tp_delay = 15, -- in seconds

	target_id = ExperienceInfo.Places.MainGame.Id, -- place id to get teleported to
}
