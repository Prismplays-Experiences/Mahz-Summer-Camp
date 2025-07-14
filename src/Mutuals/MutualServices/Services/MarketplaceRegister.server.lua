--> Services
----------------------------------------
local MarketplaceService = game:GetService('MarketplaceService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

--> Modules
----------------------------------------
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Service = require(Modules:WaitForChild('MarketService'))
local ChatNotification = require(Modules:WaitForChild('Client'):WaitForChild('ChatNotification'))

--> Modules
----------------------------------------
local SoundEffects = ReplicatedStorage:WaitForChild('Models'):WaitForChild('SoundEffects')

--> Utility Functions
----------------------------------------
local function Announce(txt)
    ChatNotification.new('Server', txt, Color3.fromRGB(185, 0, 218), 'ArimoBold')
end

local function Create_INST(TYPE, PARENT, NAME)
    local NewINST = Instance.new(TYPE)
    NewINST.Parent = PARENT
    NewINST.Name = NAME
    return NewINST
end

local function FindIndex(id, tab)
    for i, v in pairs(tab) do
        if type(v) == 'table' then
            if v.Id == id then
                return i
            end
        else
            if v == id then
                return i
            end
        end
    end
    return nil
end

local function deepCopy(original)
    local copy
    if type(original) == "table" then
        copy = {}
        for key, value in pairs(original) do
            copy[key] = deepCopy(value)
        end
    else
        copy = original
    end
    return copy
end

local function tween(itemtotween, property, value, tweentime, easingstyle, easingdirection)
    local info = TweenInfo.new(tweentime, Enum.EasingStyle[easingstyle], Enum.EasingDirection[easingdirection], 0, false, 0)
    local goal = {}
    goal[property] = value
    return game:GetService("TweenService"):Create(itemtotween, info, goal)
end

local function CreateGamepassInst(Player)
    if Player:FindFirstChild('GamepassFolder') then return end

    local GamepassFolder = Instance.new('Folder', Player)
    GamepassFolder.Name = 'GamepassFolder'

    for i, v in pairs(Service.GamepassIds) do
        local value = Instance.new('BoolValue', GamepassFolder)
        value.Name = i
        value.Value = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, v.Id)
    end
end

local function ProductPurchaseProcess(recieptinfo)
    local Player = game.Players:GetPlayerByUserId(recieptinfo.PlayerId)
    local success, productInfo = pcall(function()
        local productinfo = MarketplaceService:GetProductInfo(recieptinfo.ProductId, Enum.InfoType.Product)
        local PriceInRobux = productinfo.PriceInRobux
        Player.PrivateStats.Donate.Value += PriceInRobux
        return productinfo
    end)
    if Player then
        local Index = FindIndex(recieptinfo.ProductId, Service.ProductIds)
        
        if Index then
            local func = Service.ProductFunctions[Index]
            if func then
                Player:AddTag('FirstPurchase')
                func(Player)
                return Enum.ProductPurchaseDecision.PurchaseGranted
            end
        end
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
end

--> Initialise
----------------------------------------

MarketplaceService.ProcessReceipt = ProductPurchaseProcess

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player, productid, ispurchased)
    if not ispurchased then return end

    local Index = FindIndex(productid, Service.GamepassIds)
    if Index then
        Player.PrivateStats.RobuxSpent.Value += Service.GamepassIds[Index].Price
        local func = Service.GamepassFunctions[Index]
        if func then
            Player:AddTag('FirstPurchase')
            func(Player)
        end
    end
end)


for _, v in pairs(game.Players:GetPlayers()) do
    CreateGamepassInst(v)
end

game.Players.PlayerAdded:Connect(CreateGamepassInst)