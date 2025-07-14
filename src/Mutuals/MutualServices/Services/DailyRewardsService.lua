--> Services
----------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")


--> Knit Setup
----------------------------------------
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
local DailyRewardService = Knit.CreateService {
    Name = "RewardService",
    Client = {
        SetValue = Knit.CreateSignal(),
    }
}


--> Modules
----------------------------------------
local Modules = ReplicatedStorage:WaitForChild("Modules")
local DailyRewardData = require(Modules:WaitForChild('Client')
                                :WaitForChild("Rewards")
                                :WaitForChild("DailyRewardsData"))


--> Constants
----------------------------------------
local Hours_Before_Activated = 24
local Restart_Value = 48
local MaxDays = 5
local ClaimCooldown = {}
local ClaimTicks = {}


--> Functions
----------------------------------------
function DailyRewardService:HandleDaily(Player)
    local DataLoaded = Player:WaitForChild("DataLoaded", 99)
    if not DataLoaded then return end
    repeat task.wait() until DataLoaded.Value == true

    local DailyRewardInst = Player:WaitForChild("DailyRewardInst")
    local Due = DailyRewardInst:WaitForChild("Due")
    local Streak = DailyRewardInst:WaitForChild("Streak")
    local lastonline = DailyRewardInst:WaitForChild("lastonline")

    if lastonline.Value == "" or tonumber(lastonline.Value) == nil then
        Due.Value = true
        Streak.Value = 1
        return
    end

    local currentTime = os.time()
    local timeDifference = currentTime - tonumber(lastonline.Value)

    self.Client.SetValue:Fire(Player, timeDifference)

    local hoursPassed = timeDifference / 3600
    if hoursPassed >= Hours_Before_Activated and hoursPassed <= Restart_Value then
        if Streak.Value == MaxDays and not Due.Value then
            Due.Value = true
            Streak.Value = 1
        elseif not Due.Value then
            Streak.Value += 1
            Due.Value = true
        end
    elseif hoursPassed >= Restart_Value then
        Streak.Value = 1
        Due.Value = true
    else
        Due.Value = false
        Streak.Value = 0
    end
end

function DailyRewardService:PlayerRemoving(Player)
    local DailyRewardInst = Player:FindFirstChild("DailyRewardInst")
    if not DailyRewardInst then return end

    local Due = DailyRewardInst:FindFirstChild("Due")
    local lastonline = DailyRewardInst:FindFirstChild("lastonline")
    local ClaimedReward = DailyRewardInst:FindFirstChild("ClaimedReward")

    pcall(function()
        if tonumber(lastonline.Value) <= 0 then
            lastonline.Value = tostring(os.time())
        end
        if Due and Due.Value and ClaimedReward then
            ClaimedReward.Value = false
        end
    end)
end

function DailyRewardService.Client:SetClaim(Player, n)
    local DailyRewardInst = Player:FindFirstChild("DailyRewardInst")
    if not DailyRewardInst then return end

    local Due = DailyRewardInst:FindFirstChild("Due")
    local Streak = DailyRewardInst:FindFirstChild("Streak")

    if not Due or not Streak then return end

    if ClaimCooldown[Player.UserId] then
        ClaimTicks[Player.UserId] = (ClaimTicks[Player.UserId] or 0) + 1
        if ClaimTicks[Player.UserId] > 3 then
            -- Implement ban logic or other penalties here
            warn(Player.Name .. " tried to exploit daily reward system")
        end
        return
    end

    ClaimCooldown[Player.UserId] = true
    task.delay(86400, function()
        ClaimCooldown[Player.UserId] = nil
    end)

    if n == "d" or Streak.Value == MaxDays then
        Streak.Value = 1
    else
        Streak.Value += 1
    end
    Due.Value = true
end

function DailyRewardService.Client:GiveReward(Player, day)
    local DailyRewardInst = Player:WaitForChild("DailyRewardInst")
    local Due = DailyRewardInst:WaitForChild("Due")
    local Streak = DailyRewardInst:WaitForChild("Streak")
    local lastonline = DailyRewardInst:WaitForChild("lastonline")

    if not Due.Value then return end

    lastonline.Value = tostring(os.time())
    Due.Value = false

    local rewardFunc = DailyRewardData.Rewards["Day" .. tostring(day)]
    if rewardFunc then
        rewardFunc(Player)
    end

    self.SetValue:Fire(Player, 1)
end


--> Player Events
----------------------------------------
Players.PlayerAdded:Connect(function(player)
    DailyRewardService:HandleDaily(player)
end)

Players.PlayerRemoving:Connect(function(player)
    DailyRewardService:PlayerRemoving(player)
end)

if RunService:IsStudio() then
    for _, player in pairs(Players:GetPlayers()) do
        DailyRewardService:HandleDaily(player)
    end
end


return DailyRewardService
