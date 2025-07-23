--> Services
----------------------------------------
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

--> Modules
----------------------------------------
local WheelSpinnerContents = require("@Modules/Client/Rewards/WheelSpinnerContents")
local MarketService = require("@Modules/MarketService")

--> Assets
----------------------------------------
local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local Main = PlayerGui:WaitForChild("Main")
local Frames = Main:WaitForChild("Frames")
local Wheel = Frames:waitForChild("Wheel")
local SpinWheel = Wheel:WaitForChild("SpinWheel")
local Spinbtn = Wheel:WaitForChild("SpinButton")
local Center = SpinWheel:WaitForChild("Center")
local SpinsStat = Player:WaitForChild("PrivateStats"):WaitForChild("Spins")

--> Variables
----------------------------------------
local Chances = WheelSpinnerContents["Chances"]
local DefaultSpinId = MarketService.ProductIds["1Spin"].Id

local MaxRewards = 6
--> Knit Setup
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local SpinsController = Knit.CreateController({ Name = "SpinsController" })

--> Utility Functions
----------------------------------------

local function generateRandomIndex()
	local totalWeight = 0
	for _, weight in ipairs(Chances) do
		totalWeight = totalWeight + weight
	end
	local randomValue = math.random(1, totalWeight)
	local currentIndex = 1
	local cumulativeWeight = Chances[1]
	while randomValue > cumulativeWeight and currentIndex < #Chances do
		currentIndex = currentIndex + 1
		cumulativeWeight = cumulativeWeight + Chances[currentIndex]
	end
	return currentIndex
end

local function SpinUI(SpinningFrame, FastSpin)
	local fullSpins = FastSpin and 2 * 360 or math.random(3, 5) * 360
	local spintime = FastSpin and 2 or 10

	local randomRewardIndex = generateRandomIndex()
	local segmentAngle = 360 / MaxRewards
	local rewardAngle = ((randomRewardIndex - 1) * segmentAngle) + math.random(-15, 15)
	local totalAngle = fullSpins + rewardAngle

	local tweenInfo = TweenInfo.new(spintime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local spinTween = TweenService:Create(SpinningFrame, tweenInfo, { Rotation = totalAngle })

	spinTween:Play()
	spinTween.Completed:Wait()

	return randomRewardIndex
end

function ZeroSpins()
	if SpinsStat.Value <= 0 then
		if not Player:HasTag("FirstPurchase") then
			Spinbtn:WaitForChild("Cheaper").Visible = true
			DefaultSpinId = MarketService.ProductIds["FirstSpin"].Id
		else
			Spinbtn:WaitForChild("Cheaper").Visible = false
			DefaultSpinId = MarketService.ProductIds["1Spin"].Id
		end
	end
end

--> Main Functions
----------------------------------------

function SpinsController:KnitStart() --KnitStart()
	for _, v in pairs(SpinWheel:GetChildren()) do
		if v:IsA("Folder") then
			v.Percent.Text = (tonumber(Chances[tonumber(v.Name)]) :: number) .. "%"
		end
	end

	local spinning = false
	local function setIndicator()
		if spinning then
			Spinbtn.Spin.Text = "SPINNING"
		else
			if SpinsStat.Value < 1 then
				ZeroSpins()
				Spinbtn.Spin.Text = "SPIN"
			else
				Spinbtn.Spin.Text = string.format("SPIN! (%d)", SpinsStat.Value)
			end
		end
	end

	setIndicator()
	SpinsStat:GetPropertyChangedSignal("Value"):Connect(setIndicator)

	Spinbtn.MouseButton1Click:Connect(function()
		local WheelService = Knit.GetService("WheelService")
		if spinning then
			return
		end
		if SpinsStat.Value > 0 then
			WheelService:ValidateWheelSpinner("check")
				:andThen(function(Status, errorMessage)
					if not Status then
						if errorMessage == "purchase" then
							MarketplaceService:PromptProductPurchase(Player, MarketService.ProductIds["1Spin"].Id)
						else
							warn("Error checking wheel spinner status:", errorMessage)
						end
						return
					end
				end)
				:catch(function(err)
					warn("Error validating wheel spinner:", err)
				end)

			spinning = true
			setIndicator()
			local Prize = SpinUI(Center, false)
			if Prize then
				WheelService:ValidateWheelSpinner("reward", Prize):andThen(function() end):catch(function(err)
					warn("Error claiming wheel spinner reward:", err)
				end)
			end
			spinning = false
			setIndicator()
		else
			MarketplaceService:PromptProductPurchase(Player, DefaultSpinId)
		end
	end)

	local PurchaseBtns = {
		Btn1 = { Btn = Wheel:WaitForChild("PurchaseButtons").Buy1, ProductId = MarketService.ProductIds["1Spin"].Id }, -- {button, product}
		Btn2 = { Btn = Wheel:WaitForChild("PurchaseButtons").Buy5, ProductId = MarketService.ProductIds["5Spins"].Id },
		Btn3 = { Btn = Wheel:WaitForChild("PurchaseButtons").Buy10, ProductId = MarketService.ProductIds["10Spins"].Id },
	}
	for _, tab in pairs(PurchaseBtns) do
		local btn = tab.Btn
		local price = MarketplaceService:GetProductInfo(tab.ProductId, Enum.InfoType.Product).PriceInRobux
		btn:WaitForChild("Amount").Text = `{price}`
		btn.MouseButton1Click:Connect(function()
			MarketplaceService:PromptProductPurchase(Player, tab.ProductId)
		end)
	end
end

return SpinsController
