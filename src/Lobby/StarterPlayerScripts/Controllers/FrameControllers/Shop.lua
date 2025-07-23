local Player = game.Players.LocalPlayer

--> Services
----------------------------------------
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--> Assets
----------------------------------------
ReplicatedStorage:WaitForChild("Models")

local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main")
local Frames = Main:WaitForChild("Frames")
local MainFrame = Frames:WaitForChild("Shop")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")

local Shop = Knit.CreateController({
	Name = "Shop",
})

--> Utility Functions
----------------------------------------
function GetCanvasPosition(scroller: ScrollingFrame, DesiredFrame)
	local scroller_absolute_position = scroller.AbsolutePosition
	local button_absolute_position = DesiredFrame.AbsolutePosition

	local difference = button_absolute_position - scroller_absolute_position
	return scroller.CanvasPosition + difference
	-- // You can tween this of course.
end

local TopButtonsPos = {}

-- local ReplicatedStorage = game:GetService('ReplicatedStorage')
-- local Libs = ReplicatedStorage:WaitForChild('Libs')
-- local Modules = Libs:WaitForChild('Modules')
-- local IAPShop = require(Modules:WaitForChild('IAPShop'))
-- local Notify = require(Modules:WaitForChild('ClientPresets')).Notify
-- local SoundEffects = ReplicatedStorage:WaitForChild('Models'):WaitForChild('SoundEffects')

-- local Events = ReplicatedStorage:WaitForChild('Events')
-- local BuyPowerup = Events:WaitForChild('BuyPowerup')

-- local PlayerCurrency = Player:WaitForChild('PrivateStats'):WaitForChild('Currency')
local TweenService = game:GetService("TweenService")

local Frame = nil

function ControlPurchases(btn)
	local Gamepass = btn:GetAttribute("Gamepass")
	local Id = btn:GetAttribute("ID")

	local info

	if Gamepass then
		info = MarketplaceService:GetProductInfo(Id, Enum.InfoType.GamePass)
	else
		info = MarketplaceService:GetProductInfo(Id, Enum.InfoType.Product)
	end

	btn.MouseButton1Click:Connect(function()
		if Gamepass then
			MarketplaceService:PromptGamePassPurchase(Player, Id)
		else
			MarketplaceService:PromptProductPurchase(Player, Id)
		end
	end)
	btn:WaitForChild("TextLabel").Text = `{info.PriceInRobux}`
end

-- function PurchasePowerups(btn)
-- 	local name = btn.Name
-- 	btn = btn:WaitForChild('RobuxButton')
-- 	local Price = IAPShop[name]
-- 	local db = false
-- 	btn:WaitForChild('TextLabel').Text = Price
-- 	btn.MouseButton1Click:Connect(function()

-- 		if PlayerCurrency.Value-Price<0 then
-- 			Notify(Player,nil,'Not enough coins!',Color3.fromRGB(255, 5, 5),1.5,nil,nil,SoundEffects.Popup)
-- 			TweenService:Create(Frame:WaitForChild('InnerFrame'):WaitForChild('ScrollingFrame'),TweenInfo.new(0.7),{CanvasPosition = Vector2.new(0, 675)}):Play()
-- 			return
-- 		end
-- 		if db then return end
-- 		db=  true

-- 		local result, msg = BuyPowerup:InvokeServer(name)
-- 		if not result then
-- 			Notify(Player,nil,msg,Color3.fromRGB(255, 0, 0),nil,nil,nil,SoundEffects.Popup)
-- 		else
-- 			Notify(Player,nil,msg,Color3.fromRGB(89, 255, 0),nil,nil,nil,SoundEffects.Positive)
-- 		end
-- 		db = false
-- 	end)
-- end

function TopButtons(btn)
	local pos = TopButtonsPos[btn.Name]
	btn.MouseButton1Click:Connect(function()
		TweenService:Create(
			Frame:WaitForChild("InnerFrame"):WaitForChild("ScrollingFrame"),
			TweenInfo.new(0.7),
			{ CanvasPosition = pos }
		):Play()
	end)
end

function Shop:KnitStart()
	local Scroller = MainFrame:WaitForChild("InnerFrame"):WaitForChild("ScrollingFrame")
	TopButtonsPos = {
		Offers = GetCanvasPosition(Scroller, Scroller:WaitForChild("OfferPass")),
		Cash = GetCanvasPosition(Scroller, Scroller:WaitForChild("CashHeading")),
		Passes = GetCanvasPosition(Scroller, Scroller:WaitForChild("PassesHeading")),
		Lifes = GetCanvasPosition(Scroller, Scroller:WaitForChild("LifesHeading")),
	}
	Frame = MainFrame
	for _, v in MainFrame:GetDescendants() do
		task.spawn(function()
			if v:GetAttribute("ID") then
				ControlPurchases(v)
			end
		end)
	end

	for _, v in Frame:WaitForChild("TabsFrame"):GetChildren() do
		task.spawn(function()
			if v:IsA("GuiButton") then
				TopButtons(v)
			end
		end)
	end
end

return Shop
