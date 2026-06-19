local SoundPlayer = require("@CustomModules/SoundPlayer")
local Knit = require("@Packages/Knit")

local SoundPlayerController = Knit.CreateController({
	Name = "SoundPlayerController",
})

function SoundPlayerController.KnitInit()
	local service = Knit.GetService("SoundPlayerService")

	service.PlaySound:Connect(function(assetId)
		SoundPlayer.PlaySoundById(assetId)
	end)
end

return SoundPlayerController
