export type AssetsService = {
	PlaySoundById: (assetId: string) -> Sound,
}

local AssetsService = {}

function AssetsService.PlaySoundById(assetId: string)
	local sound = Instance.new("Sound")
	sound.SoundId = assetId
	sound.Parent = workspace

	sound:Play()

	return sound
end

return AssetsService
