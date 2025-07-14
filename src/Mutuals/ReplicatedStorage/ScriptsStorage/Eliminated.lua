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

--> Variables
----------------------------------------
local max = 7
local currenttime = max
local Result = nil
local Purchased = false


--> Main Functions
----------------------------------------
Eliminated = Knit.CreateController {
    Name = "EliminateController",
}

function Eliminated:KnitStart()
    local RoundLoop = Knit.GetService('RoundLoop')
    ReviveBtn.MouseButton1Click:Connect(function()
		self.OnPrompt = true
		MarketplaceService:PromptProductPurchase(Player,MarketModule.ProductIds.Revive.Id)
	end)
    RoundLoop.EliminatePlayer:Connect(function()
        self:Eliminate()
    end)
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
		if productid == MarketModule.ProductIds.Revive.Id then
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
		ReviveBtn.TextLabel.Text = `Revive [{currenttime}]`
		
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
	return Result
end

return Eliminated