--> Services
----------------------------------------
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

--> Modules
----------------------------------------
local MarketService = require("@Modules/MarketService")
local Knit = require("@Packages/Knit")

--> Assets
----------------------------------------
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main")
local Frames = Main:WaitForChild("Frames")
local MainFrame = Frames:WaitForChild("Shop")
local Core = Main:WaitForChild("Core")

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

function ProductBtn(Btn, ProductId)
	Btn.MouseButton1Click:Connect(function()
		MarketplaceService:PromptProductPurchase(Player, ProductId)
	end)
end

-- Main Functions
-----------------------------------------

function Shop:KnitStart()
	self.IAPFunction = Knit.GetService("IAPFunction")
	local Scroller = MainFrame:WaitForChild("InnerFrame"):WaitForChild("ScrollingFrame")
	TopButtonsPos = {
		Cash = GetCanvasPosition(Scroller, Scroller:WaitForChild("CashHeading")),
		-- Suppliments = GetCanvasPosition(Scroller, Scroller:WaitForChild("SupplimentsHeading")),
	}

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
	print("heere")
	ProductBtn(Core:WaitForChild("Plus100"), MarketService.ProductIds.Plus100.Id)
	ProductBtn(Core:WaitForChild("Plus500"), MarketService.ProductIds.Plus500.Id)
	ProductBtn(Core:WaitForChild("Plus1000"), MarketService.ProductIds.Plus1000.Id)
	ProductBtn(Core:WaitForChild("SkipDay"), MarketService.ProductIds.SkipDay.Id)
end

return Shop
