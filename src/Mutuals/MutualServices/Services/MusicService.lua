local Knit = require("@Packages/Knit")

local MusicService = Knit.CreateService({
	Name = "MusicService",
	Client = {
		PlayNewSong = Knit.CreateSignal(),
	},
})

function MusicService:NewSong(Song, Player)
	if Player then
		self.Client.PlayNewSong:Fire(Player, Song)
	else
		self.Client.PlayNewSong:FireAll(Song)
	end
end

return MusicService
