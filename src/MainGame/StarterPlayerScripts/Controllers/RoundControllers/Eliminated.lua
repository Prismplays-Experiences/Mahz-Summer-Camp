--> Services
----------------------------------------
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local MarketplaceService = game:GetService('MarketplaceService')

--> Modules
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild('Packages')
local Knit = require(Packages:WaitForChild('Knit'))
local Modules = ReplicatedStorage:WaitForChild('Modules')
local MarketModule = require(Modules:WaitForChild('MarketService'))

--> Assets
----------------------------------------
local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local EliminatedScreenGui = PlayerGui:WaitForChild('Eliminated')
local EliminatedFrame = EliminatedScreenGui:WaitForChild('Eliminated')
local Main = PlayerGui:WaitForChild('Main')
local ReviveBtn = EliminatedFrame:WaitForChild('Revive')
local ReviveUpgradeBtn = EliminatedFrame:WaitForChild('ReviveUpgrade')
local CountdownText = EliminatedFrame:WaitForChild('Countdown')

--> Variables
----------------------------------------
local max = 15
local currenttime = max
local Result = nil
local Purchased = false
local RejoinId = MarketModule.ProductIds.Rejoin.Id
local RejoinUpgradeId = MarketModule.ProductIds.RejoinUpgrade.Id


--> Main Functions
----------------------------------------
Eliminated = Knit.CreateController {
    Name = "EliminateController",
}

function Eliminated:KnitStart()
    local LifeService = Knit.GetService('LifeService')
	self.SpectateController = Knit.GetController('SpectateController')
	ReviveUpgradeBtn:WaitForChild('Price').Text = MarketModule.ProductIds.RejoinUpgrade.Price..' Robux'
	ReviveBtn:WaitForChild('Price').Text = MarketModule.ProductIds.Rejoin.Price..' Robux'
    ReviveBtn.MouseButton1Click:Connect(function()
		self.OnPrompt = true
		MarketplaceService:PromptProductPurchase(Player,MarketModule.ProductIds.Rejoin.Id)
	end)
	ReviveUpgradeBtn.MouseButton1Click:Connect(function()
		self.OnPrompt = true
		MarketplaceService:PromptProductPurchase(Player,MarketModule.ProductIds.RejoinUpgrade.Id)
	end)
    LifeService.EliminatePlayer:Connect(function()
        self:Eliminate()
    end)
end

function RoundTo1DP(num)
	return math.floor(num * 10 + 0.5) / 10
end

function Eliminated:Eliminate()
	self.OnPrompt = false
	Main.Enabled = false
	EliminatedScreenGui.Enabled = true
	EliminatedFrame.Visible = true

	local Prompted = MarketplaceService.PromptProductPurchaseFinished:Connect(function(userid,productid,waspurchased)
		self.OnPrompt = false
		currenttime = max
		local idcheck = false
		if productid == MarketModule.ProductIds.Rejoin.Id or productid == MarketModule.ProductIds.RejoinUpgrade.Id then
			idcheck = true
		end
		if userid == Player.UserId and idcheck and waspurchased then
			Purchased = true
			Result = true
			currenttime = 0
		end
	end)
	local Resolution = 0.1
	while currenttime > 0 do
		task.wait(Resolution)
		if not self.OnPrompt then
			currenttime -= Resolution
		end
		CountdownText.Text = `{RoundTo1DP(currenttime)}s`
		
		if currenttime<=0 and not Purchased then
			Result = false
			break
		end	
	end

	repeat task.wait() until Result~= nil
	EliminatedScreenGui.Enabled = false
	EliminatedFrame.Visible = false
	Player.PlayerGui:WaitForChild('Main').Enabled = true
	Prompted:Disconnect()
	if not Result then
		self.SpectateController:Open()
		self:MoveOutMap()
	end
	return Result
end

function Eliminated:MoveOutMap()
	local OuterSpawnPoints = workspace:WaitForChild('Game'):WaitForChild('OuterSpawnPoints')
	local spawnPoints = OuterSpawnPoints:GetChildren()
	local SpawnPoint = spawnPoints[math.random(1, #spawnPoints)]

	Player.Character:MoveTo(SpawnPoint.Position)
end

return Eliminated