local ReplicatedStorage = game:GetService("ReplicatedStorage")

local npcCache = require(ReplicatedStorage.Packages.chrono.shared.npcCache)

do
    return
end

local player = game:GetService("Players").PlayerAdded:Wait()
task.wait(1)
local model = player.Character or player.CharacterAdded:Wait()
model.Archivable = true

local clone = model:Clone()
clone.Parent = workspace

npcCache.Register(clone, "DEFAULT", "TestNPCs", true)
