--> Services
----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--> Modules
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

--> Assets
----------------------------------------
local Models = ReplicatedStorage:WaitForChild("Models")
local Music = Models:WaitForChild('Musics')

--> Variables
----------------------------------------
local folderStates = {}
local currentFolder = nil
local soundEndedConnection = nil

--> Utility Functions
----------------------------------------
local function FindMusic(folderName)
    local folder = Music:FindFirstChild(folderName, true)
    if not folder or not folder:IsA("Folder") then return nil end
    return folder
end

local function GetRandomSongFromFolder(folder)
    local songs = {}
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("Sound") then
            table.insert(songs, child)
        end
    end
    if #songs == 0 then return nil end
    return songs[math.random(1, #songs)]
end


--> Main Functions
----------------------------------------
local MusicService = Knit.CreateController {
    Name = "MusicController",
    Client = {},
}

function MusicService:StopMusic()
    for _, state in pairs(folderStates) do
        if state.sound and state.sound:IsA("Sound") then
            state.sound:Stop()
        end
    end
    folderStates = {}
end

function MusicService:PauseCurrentSong()
    if currentFolder and folderStates[currentFolder] then
        local state = folderStates[currentFolder]
        if state.sound and state.sound:IsA("Sound") and state.sound.IsPlaying then
            state.sound:Pause()
            state.isPaused = true
        end
    end
end

function MusicService:ResumeSong(folder)
    local state = folderStates[folder]
    if state and state.sound and state.sound:IsA("Sound") then
        if state.isPaused then
            state.sound:Play()
            state.isPaused = false
        elseif not state.sound.IsPlaying then
            state.sound:Play()
        end
    end
end

function MusicService:PlayNewSongInFolder(folder)
    if soundEndedConnection then
        soundEndedConnection:Disconnect()
        soundEndedConnection = nil
    end
    local newSong = GetRandomSongFromFolder(folder)
    if newSong and newSong:IsA("Sound") then
        folderStates[folder] = {
            sound = newSong,
            isPaused = false
        }
        newSong:Play()
        soundEndedConnection = newSong.Ended:Connect(function()
            self:PlayNewSongInFolder(folder)
        end)
    else
        folderStates[folder] = nil
    end
end

function MusicService:PlayNewSong(folderName)
    local folder = FindMusic(folderName)
    if not folder then return end
    self:PauseCurrentSong()
    if folderStates[folder] then
        self:ResumeSong(folder)
    else
        self:PlayNewSongInFolder(folder)
    end
    currentFolder = folder
end

function MusicService:KnitStart()
    local MusicService = Knit.GetService("MusicService")
    MusicService.PlayNewSong:Connect(function(folderName)
        if currentFolder == folderName then
            return
        end
        self:PlayNewSong(folderName)
    end)
    self:PlayNewSong("Normal")
end

return MusicService
