--> Services
----------------------------------------
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")
local MarketModule = require("@Modules/MarketService")

--> Assets
----------------------------------------
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main")
local Frames = Main:WaitForChild("Frames")
local StarterPackFrame = Frames:WaitForChild("StarterPack")
local StarterPackButton = Frames:WaitForChild("StarterPackBtn")
local Timer = StarterPackButton:WaitForChild("Timer")
local BuyBtn = StarterPackFrame:WaitForChild("Buy")

--> Knit Setup
----------------------------------------
local StarterPack = Knit.CreateController({
	Name = "StarterPack",
})

--> Variables
----------------------------------------
local MaxTime = 5 * 60
local CurrentTime = MaxTime
local Id = MarketModule.GamepassIds.StarterPack.Id
local Price = MarketModule.GamepassIds.StarterPack.Price

--> Utility Functions
----------------------------------------

function FormatTime(Time)
	local TimeFormat = "%d:%02d"
	local m = math.floor(Time / 60)
	local s = math.floor(Time % 60)
	local t = string.format(TimeFormat, m, s)
	return t
end

function SendNotification(msg, color, duration, reward, sound)
	local Notify = Knit.GetController("UINotificationsController")
	Notify:ShowNotification({
		message = msg,
		color = color or Color3.fromRGB(255, 255, 255),
		duration = duration or 2,
		reward = reward or false,
		sound = sound,
	})
end

function UpdateTime()
	CurrentTime -= 1
	Timer.Text = FormatTime(CurrentTime)
end

--> Main Functions
----------------------------------------

function StarterPack:KnitStart()
	StarterPackButton.Visible = false
	self.GeneralGameplay = Knit.GetService("GeneralGameplay")
	if Player:WaitForChild("GamepassFolder"):WaitForChild("StarterPack").Value then
		return
	end
	StarterPackButton.Visible = true
	BuyBtn:WaitForChild("Text").Text = `{utf8.char(0xE002)}{Price}`
	BuyBtn.MouseButton1Click:Connect(function()
		MarketplaceService:PromptGamePassPurchase(Player, Id)
	end)
	while task.wait(1) and not Player:WaitForChild("GamepassFolder"):WaitForChild("StarterPack").Value do
		UpdateTime()
		if CurrentTime <= 0 then
			SendNotification("LAST CHANCE! Starter pack expiring..", Color3.fromRGB(255, 0, 0), 7)
			StarterPackFrame.Visible = true
			StarterPackFrame.UIScale.Scale = 1
			Timer.Text = FormatTime(CurrentTime)
			StarterPackButton.Visible = false
		end
		break
	end
	self.GeneralGameplay:SetStarterPack()
	StarterPackButton.Visible = false
	StarterPackFrame.Visible = false
end

return StarterPack
