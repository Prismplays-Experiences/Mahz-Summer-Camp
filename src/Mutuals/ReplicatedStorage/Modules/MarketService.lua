local Knit = require(game:GetService('ReplicatedStorage'):WaitForChild('Packages'):WaitForChild('Knit'))

local MarketService = {}

local CollectionService = game:GetService('CollectionService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules =script.Parent
local ChatNotification = require(Modules.Client.ChatNotification)
-- local GeneralService = require(Libs:WaitForChild('GeneralServiceModule'))

local Models = ReplicatedStorage:WaitForChild('Models')
local SoundEffects = Models:WaitForChild('SoundEffects')

local ServerScript = game:GetService('ServerScriptService')

local GeneralInfo = require(ReplicatedStorage:WaitForChild('Info'):WaitForChild('GeneralInfo'))

local runservice = game:GetService('RunService')

function SendNotification(player,msg,color,duration,reward,sound)
    local Notify = Knit.GetService('NotificationService')
    Notify:SendNotification(player,{
        message = msg,
        color = color or Color3.fromRGB(255, 255, 255),
        duration = duration or 2,
        reward = reward or false,
        sound = sound or SoundEffects.Positive})
end

function DefaultPurchaseEvent(Player)
    local Notify = Knit.GetService('NotificationService')
	Notify:SendNotification(Player,{
        message = 'Thanks for the purchase ❤️',
        color = Color3.fromRGB(40, 217, 0),
        duration = 2,
        reward = true,
        sound = SoundEffects.Positive})
end

function Announce(txt)
	ChatNotification.new('Server',txt, Color3.fromRGB(182, 218, 0),'Roboto')
end

function GivePlayerMoney(Player,Amount)
	Player.PrivateStats.Currency.Value+=Amount
	SendNotification(Player,`{Amount} Coins!`,Color3.fromRGB(255, 183, 0))
end

MarketService.GamepassIds = {
	['VIP'] = {Price = 149, Id  = 1309476388},
	['DoubleCoins'] = {Price = 149, Id  = 1305715966},
	
}

MarketService.ProductIds = {
	['FirstSpin'] = {Price = 19, Id = 3324330793},
	['1Spin'] = {Price = 49, Id = 3324330805},
	['5Spins'] = {Price = 199, Id = 3324330800},
	['10Spins'] = {Price = 399, Id = 3324330799},

	['Rejoin'] = {Price = 19, Id = 3319855182},
	['RejoinUpgrade'] = {Price = 49, Id = 3324330807},

	['1Life'] = {Price = 49, Id = 3324330803},
	['3Life'] = {Price = 49, Id = 3324330802},
	['5Lifes'] = {Price = 199, Id = 3324330798},
	['10Lifes'] = {Price = 399, Id = 3324330801},

	['500Coins'] = {Price = 49, Id = 3329031265},
	['1000Coins'] = {Price = 49, Id = 3329031264},
	['5000Coins'] = {Price = 199, Id = 3329031258},
	['10000Coins'] = {Price = 399, Id = 3329031263},
	['50000Coins'] = {Price = 399, Id = 3329031272},

	['OPPack'] = {Price = 79, Id = 3329031271},

	['InjuryRecovery'] = {Price = 19, Id = 3328138304},

	['TreadmillUnlock'] = {Price = 19, Id = 3329031259},
	['BenchPressUnlock'] = {Price = 19, Id = 3329031262},
	['DipsUnlock'] = {Price = 19, Id = 3329031261},
	['DumbellCurlUnlock'] = {Price = 19, Id = 3329031260},

	['1.2xWeightLoss'] = {Price = 19, Id = 3340140921},
	['1.4xWeightLoss'] = {Price = 49, Id = 3340140919},
	['1.6xWeightLoss'] = {Price = 49, Id = 3340140922},
	['1.8xWeightLoss'] = {Price = 49, Id = 3340140923},
	['2xWeightLoss'] = {Price = 49, Id = 3339707427},
	['2.4xWeightLoss'] = {Price = 199, Id = 3340140917},
	['2.8xWeightLoss'] = {Price = 199, Id = 3340140918},
	['3xWeightLoss'] = {Price = 199, Id = 3339707424},
	['3.2xWeightLoss'] = {Price = 399, Id = 3340140915},
	['4xWeightLoss'] = {Price = 399, Id = 3339707425},
}

local MPS = game:GetService('MarketplaceService')
function UpdatePrice()
	for i,v in pairs(MarketService.ProductIds) do
		pcall(function()
			local productinfo = MPS:GetProductInfo(v.Id, Enum.InfoType.Product)
			v.Price = productinfo.PriceInRobux
		end)
	end
	for i,v in pairs(MarketService.GamepassIds) do
		pcall(function()
			local productinfo = MPS:GetProductInfo(v.Id, Enum.InfoType.GamePass)
			v.Price = productinfo.PriceInRobux
		end)
	end
end
UpdatePrice()
game.Players.PlayerAdded:Connect(UpdatePrice)

MarketService.ProductFunctions = {
	['FirstSpin'] = function(Player)
		Player:AddTag('FirstPurchase')
		DefaultPurchaseEvent(Player)
		SendNotification(Player,'+1 Spin',Color3.fromRGB(217, 156, 0),5)
		local profile = Player:WaitForChild('PrivateStats')
		profile.Spins.Value+=1
	end,
	['1Spin'] = function(Player)
		DefaultPurchaseEvent(Player)
		SendNotification(Player,'+1 Spin',Color3.fromRGB(217, 156, 0),5)
		local profile = Player:WaitForChild('PrivateStats')
		profile.Spins.Value+=1
	end,
	['5Spins'] = function(Player)
		DefaultPurchaseEvent(Player)
		SendNotification(Player,'+5 Spin',Color3.fromRGB(217, 156, 0),5)
		local profile = Player:WaitForChild('PrivateStats')
		profile.Spins.Value+=5
	end,
	['10Spins'] =  function(Player)
		DefaultPurchaseEvent(Player)
		SendNotification(Player,'+10 Spin',Color3.fromRGB(217, 156, 0),5)
		local profile = Player:WaitForChild('PrivateStats')
		profile.Spins.Value+=10
	end,

	['Rejoin'] =  function(Player)
		DefaultPurchaseEvent(Player)
		local LifeService = Knit.GetService('LifeService')
		LifeService:RevivePlayer(Player)
	end,

	['RejoinUpgrade'] = function(Player)
		DefaultPurchaseEvent(Player)
		local LifeService = Knit.GetService('LifeService')
		LifeService:RevivePlayer(Player,50)
	end,

	['1Life'] = function(Player)
		DefaultPurchaseEvent(Player)
		local PrivateStats = Player:WaitForChild('PrivateStats')
		PrivateStats.Lifes.Value+=1
	end,
	['3Life'] = function(Player)
		DefaultPurchaseEvent(Player)
		local PrivateStats = Player:WaitForChild('PrivateStats')
		PrivateStats.Lifes.Value+=3
	end,
	['5Lifes'] = function(Player)
		DefaultPurchaseEvent(Player)
		local PrivateStats = Player:WaitForChild('PrivateStats')
		PrivateStats.Lifes.Value+=5
	end,
	['10Lifes'] = function(Player)
		DefaultPurchaseEvent(Player)
		local PrivateStats = Player:WaitForChild('PrivateStats')
		PrivateStats.Lifes.Value+=10
	end,

	['500Coins'] = function(Player)
		DefaultPurchaseEvent(Player)
		GivePlayerMoney(Player,500)
	end,
	['1000Coins'] = function(Player)
		DefaultPurchaseEvent(Player)
		GivePlayerMoney(Player,1000)
	end,
	['5000Coins'] = function(Player)
		DefaultPurchaseEvent(Player)
		GivePlayerMoney(Player,5000)
	end,
	['10000Coins'] = function(Player)
		DefaultPurchaseEvent(Player)
		GivePlayerMoney(Player,10000)
	end,
	['50000Coins'] = function(Player)
		DefaultPurchaseEvent(Player)
		GivePlayerMoney(Player,50000)
	end,

	['OPPack'] = function(Player)
		DefaultPurchaseEvent(Player)
		GivePlayerMoney(Player,10000)
		local PrivateStats = Player:WaitForChild('PrivateStats')
		PrivateStats.Lifes.Value+=10
		PrivateStats.Spins.Value+=5
	end,

	['InjuryRecovery'] = function(Player)
		DefaultPurchaseEvent(Player)
		local GeneralService = Knit.GetService('GeneralGameplay')
		GeneralService.Client:SetInjured(Player, false)
	end,

	['TreadmillUnlock'] = function(Player)
		DefaultPurchaseEvent(Player)
		local PrivateStats = Player:WaitForChild('PrivateStats')
		local LockedCap = PrivateStats:waitForChild('LockedCap')
		LockedCap.Value = GeneralInfo.WorkoutStartDays.Treadmill.Day
	end,
	['BenchPressUnlock'] = function(Player)
		DefaultPurchaseEvent(Player)
		local PrivateStats = Player:WaitForChild('PrivateStats')
		local LockedCap = PrivateStats:waitForChild('LockedCap')
		LockedCap.Value = GeneralInfo.WorkoutStartDays.BenchPress.Day
	end,
	['DipsUnlock'] = function(Player)
		DefaultPurchaseEvent(Player)
		local PrivateStats = Player:WaitForChild('PrivateStats')
		local LockedCap = PrivateStats:waitForChild('LockedCap')
		LockedCap.Value = GeneralInfo.WorkoutStartDays.Dips.Day
	end,
	['DumbellCurlUnlock'] = function(Player)
		DefaultPurchaseEvent(Player)
		local PrivateStats = Player:WaitForChild('PrivateStats')
		local LockedCap = PrivateStats:waitForChild('LockedCap')
		LockedCap.Value = GeneralInfo.WorkoutStartDays.DumbellCurl.Day
	end,

	['1.2xWeightLoss'] = function(Player)
		DefaultPurchaseEvent(Player)
		Player:SetAttribute('WeightLossMultiplier', 1.2)
	end,
	['1.4xWeightLoss'] = function(Player)
		DefaultPurchaseEvent(Player)
		Player:SetAttribute('WeightLossMultiplier', 1.4)
	end,
	['1.6xWeightLoss'] = function(Player)
		DefaultPurchaseEvent(Player)
		Player:SetAttribute('WeightLossMultiplier', 1.6)
	end,
	['1.8xWeightLoss'] = function(Player)
		DefaultPurchaseEvent(Player)
		Player:SetAttribute('WeightLossMultiplier', 1.8)
	end,
	['2xWeightLoss'] = function(Player)
		DefaultPurchaseEvent(Player)
		Player:SetAttribute('WeightLossMultiplier', 2)
	end,
	['2.4xWeightLoss'] = function(Player)
		DefaultPurchaseEvent(Player)
		Player:SetAttribute('WeightLossMultiplier', 2.4)
	end,
	['2.8xWeightLoss'] = function(Player)
		DefaultPurchaseEvent(Player)
		Player:SetAttribute('WeightLossMultiplier', 2.8)
	end,
	['3xWeightLoss'] = function(Player)
		DefaultPurchaseEvent(Player)
		Player:SetAttribute('WeightLossMultiplier', 3)
	end,
	['3.2xWeightLoss'] = function(Player)
		DefaultPurchaseEvent(Player)
		Player:SetAttribute('WeightLossMultiplier', 3.2)
	end,
	['4xWeightLoss'] = function(Player)
		DefaultPurchaseEvent(Player)
		Player:SetAttribute('WeightLossMultiplier', 4)
	end,
}

MarketService.GamepassFunctions = {
	['VIP'] = function(Player)
		Announce(`{Player.Name} bought VIP!`)
		DefaultPurchaseEvent(Player)
		local GamepassFolder = Player:WaitForChild('GamepassFolder')
		GamepassFolder.VIP.Value = true

	end,
	['StarterPack'] = function(Player)
		Announce(`{Player.Name} bought STARTER PACK!`)
		DefaultPurchaseEvent(Player)
		local Powerups = Player:WaitForChild('Powerups')
		local Freeze = Powerups:WaitForChild('Freeze')
		local Speed = Powerups:WaitForChild('Speed')
	end,
	['DoubleCoins'] = function(Player)
		DefaultPurchaseEvent(Player)
		local PrivateStats = Player:WaitForChild('PrivateStats')
		local GamepassFolder = Player:WaitForChild('GamepassFolder')
		GamepassFolder.DoubleCoins.Value = true
	end,
}


return MarketService
