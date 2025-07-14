local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Packages = ReplicatedStorage:WaitForChild('Packages')
local Knit = require(Packages:WaitForChild('Knit'))

MusicService = Knit.CreateService {
    Name = 'MusicService',
    Client = {
        PlayNewSong = Knit.CreateSignal()
    }
}

function MusicService:NewSong(Song,Player)
    if Player then
        self.Client.PlayNewSong:Fire(Player, Song)
    else
        self.Client.PlayNewSong:FireAll(Song)
    end
end

return MusicService