--> Services
----------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService('ServerStorage')
-- local RunService = game:GetService("RunService")

--> Modules
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Signal = require(Packages:WaitForChild("Signal"))
local Knit = require(Packages:WaitForChild("Knit"))
local GeneralInfo = require(ReplicatedStorage:WaitForChild("Info"):WaitForChild("GeneralInfo"))

--> Variables
----------------------------------------
local MinutesPerDay = 6

--> Knit Setup
----------------------------------------
local LifeService = Knit.CreateService {
    Name = "LifeService",
    DayEnded = Signal.new(),
    Client = {
        EliminatePlayer = Knit.CreateSignal(),
    }
}

--> Utility Functions
----------------------------------------

--> Main Functions
----------------------------------------
function LifeService:Refill(Player)
    Player.leaderstats.Lifes.Value = GeneralInfo.MaxLifes
end

function LifeService:GetEliminated()
    -- return {game.Players:FindFirstChild('1_mahz')}
    local eliminated = {}
    for _,plr in game.Players:GetPlayers() do
        if plr:HasTag('Eliminated') then 
            table.insert(eliminated,plr)
        end
    end
    return eliminated
end

function LifeService:EliminatePlayer(plr)
    plr.leaderstats.Loses.Value +=1
    plr:AddTag('Eliminated')
    self.StageService:Eliminated(true)
    self.Client.EliminatePlayer:Fire(plr)
end

function LifeService.Client:LifeRefillEvent(Player)
    local StoredLifes = Player.PrivateStats.Lifes
    if StoredLifes.Value>0 then
        StoredLifes.Value -=1
        task.spawn(function() 
            self.Server:Refill(Player) 
        end)
        return true
    else
        return false
    end
end

function LifeService:RevivePlayer(Player,Weight)
    Player.leaderstats.Loses.Value -=1
    Player.leaderstats.Lifes.Value = GeneralInfo.MaxLifes
    Player:RemoveTag('Eliminated')
    -- local Day = self.ClockService:GetDay() 
    Player.leaderstats.Weight.Value = GeneralInfo.Weight - (self.TargetService.TotalWeightLost or 1)
    if Weight and tonumber(Weight) then
        Player.leaderstats.Weight.Value = math.clamp(Player.leaderstats.Weight.Value - tonumber(Weight), GeneralInfo.EndWeight, GeneralInfo.Weight)
    end
    print('Weight after revive: '..Player.leaderstats.Weight.Value)
    -- pcall(function()
        Player.Character:MoveTo(workspace.Game.SpawnLocations.SpawnLocation.Position+Vector3.new(0,5,0))
    -- end)
end

function LifeService:KnitStart()

    self.StageService = Knit.GetService('StageService')
    self.ClockService = Knit.GetService('ClockService')
    self.TargetService = Knit.GetService('TargetService')
end

return LifeService