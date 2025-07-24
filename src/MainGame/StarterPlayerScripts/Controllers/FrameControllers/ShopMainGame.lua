--> Services
----------------------------------------
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")
local IAPDATA = require("@Info/IAPDATA")

--> Assets
----------------------------------------
local Models = ReplicatedStorage:WaitForChild("Models")
local SoundEffects = Models:WaitForChild("SoundEffects")

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main")
local Frames = Main:WaitForChild("Frames")
local MainFrame = Frames:WaitForChild("Shop")
local UseSupplimentBtn = Main:WaitForChild("Core"):WaitForChild("UseSuppliment")

--> Knit Setup
----------------------------------------
local Shop = Knit.CreateController({
	Name = "Shop",
})

--> Variables
----------------------------------------
local TopButtonsPos = {}

--> Utility Functions
----------------------------------------
function GetCanvasPosition(scroller: ScrollingFrame, DesiredFrame)
	local scroller_absolute_position = scroller.AbsolutePosition
	local button_absolute_position = DesiredFrame.AbsolutePosition

	local difference = button_absolute_position - scroller_absolute_position
	return scroller.CanvasPosition + difference
end

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

function TopButtons(btn)
	local pos = TopButtonsPos[btn.Name]
	btn.MouseButton1Click:Connect(function()
		TweenService:Create(
			MainFrame:WaitForChild("InnerFrame"):WaitForChild("ScrollingFrame"),
			TweenInfo.new(0.7),
			{ CanvasPosition = pos }
		):Play()
	end)
end

function SendNotification(msg, color, duration, reward, sound)
	local Notify = Knit.GetController("UINotificationsController")
	Notify:ShowNotification({
		message = msg,
		color = color or Color3.fromRGB(255, 255, 255),
		duration = duration or 2,
		reward = reward or false,
		sound = sound or SoundEffects.Positive,
	})
end

-- Main Functions
-----------------------------------------
function Shop:PurchaseWithCoins(Frame)
	if not Frame.Visible then
		return
	end
	local btn = Frame:WaitForChild("BuyBtn")
	btn:WaitForChild("Price").Text = `{IAPDATA.Suppliments[Frame.Name].Cost}`

	btn.MouseButton1Click:Connect(function()
		self.IAPFunction
			:Purchase(Frame.Name)
			:andThen(function(success, msg)
				if success then
					SendNotification(msg, Color3.fromRGB(89, 255, 0), nil, true, SoundEffects.Positive)
				else
					SendNotification(msg, Color3.fromRGB(255, 0, 0), nil, nil, SoundEffects.UIDeny)
				end
			end)
			:catch(function(err)
				warn(`Error purchasing {Frame.Name}: {err}`)
			end)
	end)
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

function Shop:KnitStart()
	self.IAPFunction = Knit.GetService("IAPFunction")
	local Scroller = MainFrame:WaitForChild("InnerFrame"):WaitForChild("ScrollingFrame")
	TopButtonsPos = {
		Events = GetCanvasPosition(Scroller, Scroller:WaitForChild("Events")),
		Cash = GetCanvasPosition(Scroller, Scroller:WaitForChild("CashHeading")),
		Suppliments = GetCanvasPosition(Scroller, Scroller:WaitForChild("SupplimentsHeading")),
	}

	for _, v in Scroller:WaitForChild("Suppliments"):GetChildren() do
		if v:IsA("GuiObject") then
			task.spawn(function()
				self:PurchaseWithCoins(v)
			end)
		end
	end

	for _, v in MainFrame:GetDescendants() do
		task.spawn(function()
			if v:GetAttribute("ID") then
				ControlPurchases(v)
			end
		end)
	end

	for _, v in MainFrame:WaitForChild("TabsFrame"):GetChildren() do
		task.spawn(function()
			if v:IsA("GuiButton") then
				TopButtons(v)
			end
		end)
	end

	Player.Backpack.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") and IAPDATA.Suppliments[tool.Name] then
			tool.Equipped:Connect(function()
				-- task.wait(1)
				self.CurrentSuppliment = tool.Name
				UseSupplimentBtn.Visible = true
			end)
			tool.Unequipped:Connect(function()
				self.CurrentSuppliment = nil
				UseSupplimentBtn.Visible = false
			end)
		end
	end)
	local db = false
	UseSupplimentBtn.MouseButton1Click:Connect(function()
		if db then
			return
		end
		db = true
		task.delay(3, function()
			db = false
		end)
		if self.CurrentSuppliment then
			local tool = Player.Character:FindFirstChild(self.CurrentSuppliment)
			if tool then
				self.IAPFunction:UseSuppliment(tool)
			end
		end
	end)
	-- for i,v in Scroller:WaitForChild('Events'):GetChildren() do
	-- 	if v:IsA('GuiObject') then
	-- 		ControlPurchases(v)
	-- 	end
	-- end
end

return Shop
