local SoundPlayer = require("@CustomModules/SoundPlayer")
local Knit = require("@Packages/Knit")

type SoundPlayerService = {[any]: any}

local SoundPlayerService = Knit.CreateService({
	Name = "SoundPlayerService",
	Client = {
		PlaySound = Knit.CreateSignal(),
	},
})

function SoundPlayerService.PlaySoundById(self: SoundPlayerService, assetId: string, player: Player?)
	if player then
		self.Client.PlaySound:Fire(player, assetId)
	end

	return SoundPlayer.PlaySoundById(assetId)
end

return SoundPlayerService
