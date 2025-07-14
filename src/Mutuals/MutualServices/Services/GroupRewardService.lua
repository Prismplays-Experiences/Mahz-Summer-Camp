--> Services
----------------------------------------
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--> Packages
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild('Packages')
local Knit = require(Packages:WaitForChild("Knit"))

local Modules = ReplicatedStorage:WaitForChild('Modules')
local GameInfo = require(Modules:WaitForChild('GameInfo'))

--> Assets
----------------------------------------
local SoundEffects = ReplicatedStorage:WaitForChild('Models'):WaitForChild('SoundEffects')

--> Utility Functions
----------------------------------------

function SendNotification(player,msg,color,duration,reward,sound)
    local Notify = Knit.GetService('NotificationService')
    Notify:SendNotification(player,{
        message = msg,
        color = color or Color3.fromRGB(255, 255, 255),
        duration = duration or 2,
        reward = reward or false,
        sound = sound or SoundEffects.Positive})
end

function CheckClaimed(Player)
    return Player.PrivateStats.GroupReward.Value
end
function CheckInGroup(Player)
    if Player:IsInGroup(GameInfo.GroupId) then
        return true
    else 
        return false
    end
end
function ClaimReward(Player)
    Player.PrivateStats.GroupReward.Value = true
    Player.PrivateStats.Currency.Value+=75
    SendNotification(Player, '+75 Coins!', Color3.fromRGB(255, 196, 0), 4, true )
end

--> Main Functions
----------------------------------------
local GroupRewardService = Knit.CreateService {
    Name = "GroupRewardService",
    Client = {

    },
}

function GroupRewardService.Client:ClaimReward(Player)
    if not CheckInGroup(Player) then
        return false, ' Like the game + Join the group!'
    end
    if CheckClaimed(Player) then
        return false, 'Already Claimed'
    else
        ClaimReward(Player)
        return true, 'Claimed!'
    end
end

return GroupRewardService