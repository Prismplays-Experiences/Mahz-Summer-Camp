--> Services
----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService('TweenService')
local MarketplaceService = game:GetService('MarketplaceService')
-- local RunService = game:GetService("RunService")

--> Modules
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Signal = require(Packages:WaitForChild("Signal"))
local Trove = require(Packages:WaitForChild("Trove")).new()
local Knit = require(Packages:WaitForChild("Knit"))
local Modules = ReplicatedStorage:WaitForChild("Modules")
local MarketModule = require(Modules:WaitForChild('MarketService'))

--> Assets
----------------------------------------
local Player = game.Players.LocalPlayer
local leaderstats = Player:WaitForChild('leaderstats')
local LifesValue = leaderstats:WaitForChild('Lifes')
local PlayerGui = Player.PlayerGui
local Main = PlayerGui:WaitForChild('Main')
local HUD = Main:WaitForChild('HUD')

local LifesFrame = HUD:WaitForChild('LifesFrame')
-- local Timer = HUD:WaitForChild('Timer')
-- local TargetWeightTxt = HUD:WaitForChild('TargetWeight')
-- local WeightTxt = HUD:WaitForChild('Weight')

local Frames = Main:WaitForChild('Frames')
local TargetFrame = Frames:WaitForChild('TargetFrame')

local Models = ReplicatedStorage:WaitForChild('Models')
local SoundEffects = Models:WaitForChild('SoundEffects')

local HealthPopupUI = LifesFrame:WaitForChild('HealthLost')


--> Variables
----------------------------------------
local MaxLifes = 2
local lasthealth = MaxLifes
local FullHeart = 'rbxassetid://81386705914770'
local EmptyHeart = 'rbxassetid://85000506565870'
local TimerFiller = HealthPopupUI:WaitForChild('Count')
local Pause = false
local bought = false

--> Knit Setup
----------------------------------------
local LifesController = Knit.CreateController {
    Name = "LifesController",
}

--> Utility Functions
----------------------------------------
function ConvertToTime(totalMinutes)
    local hours = math.floor(totalMinutes / 60)
    local minutes = totalMinutes % 60
    return string.format("%02d:%02d", hours, minutes)
end

function OpenFrame(Frame, Pos)
	
	Frame.Position = Pos or Frame.Position
	local UIScale = Frame:FindFirstChild('UIScale') or Instance.new('UIScale',Frame)
	UIScale.Scale = 0

	local OpenTween = TweenService:Create(UIScale,
		TweenInfo.new(0.5,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out),
		{Scale = 1}
	)
	local CloseTween = TweenService:Create(UIScale,
		TweenInfo.new(0.7,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),
		{Scale = 0}
	)

	OpenTween:Play()
	Frame.Visible = true
	local function Close()
		CloseTween:Play()
		CloseTween.Completed:Once(function()
			Frame.Visible = false
		end)
	end
	return Close

end

closepopup = nil

function PlayHealthPopup()
	bought = false
	local Time =10
	HealthPopupUI.Visible = true
	TweenService:Create(HealthPopupUI.UIScale,TweenInfo.new(0.5,Enum.EasingStyle.Back),{Scale = 1}):Play()
	local func
	local closing = false
	closepopup = function()
		TweenService:Create(HealthPopupUI.UIScale,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{Scale = 0}):Play()
		func:Disconnect()
		closing = true
	end

	func = Trove:Connect(
    MarketplaceService.PromptProductPurchaseFinished,
    function(userId, productId, isPurchased)
        if userId ~= Player.UserId then return end

        local lifeProductId = MarketModule.ProductIds["1Life"].Id
        if productId ~= lifeProductId then return end

        if isPurchased then
            bought = true
            closepopup()
        else
            Time = 5
            Pause = false
        end
    end
)

	
	while Time > 0 do
		task.wait(0.1)  -- Waits 1 second between updates
		if not Pause then
			Time -= 0.1
		end
		if bought then break end

		TimerFiller.TextLabel.Text = RoundTo1DP(Time)
		if Time<=0 then
			closepopup()
			break
		end	
		if closing then break end
	end
	if not bought then
		LifesFrame.RefillLifes.Visible = true
	end

	if not closing then closepopup() end
end

function RoundTo1DP(num)
	return math.floor(num * 10 + 0.5) / 10
end
--> Main Functions
----------------------------------------

function LifesController:UpdateLifes(healthleft)
	if healthleft == lasthealth then return end
	lasthealth = healthleft
	if healthleft == MaxLifes then
		LifesFrame.RefillLifes.Visible = false
		for _, v in ipairs(LifesFrame:WaitForChild('Container'):GetChildren()) do
			if tonumber(v.Name) then
				v.Image = FullHeart
			end
		end
		return
	elseif healthleft>0 then 
		task.delay(3.5,PlayHealthPopup)
		--RoundLoopService:GetPlayerCount():andThen(function(count)
			--if count>=3 then
				
			--end
	
		--end)
	end
	
	local downinfo = TweenInfo.new(1)
	local upinfo = TweenInfo.new(1.5)

	for i = 1, healthleft do
		local healthIcon = LifesFrame:WaitForChild('Container'):FindFirstChild(tostring(i))
		--if healthIcon and i > healthleft then
		if not healthIcon then warn('healthicon not found') return end
		local UIScaleHealth = healthIcon:WaitForChild('UIScale')
		local EffectUI = healthIcon:WaitForChild('EffectUi')
		local UIScaleEffect = EffectUI:WaitForChild('UIScale')

		EffectUI.Visible = true
		UIScaleEffect.Scale = 0
		EffectUI.ImageTransparency = 0
		TweenService:Create(UIScaleEffect, upinfo, {Scale = 1.5}):Play()
		TweenService:Create(EffectUI, upinfo, {ImageTransparency = 1}):Play()

		TweenService:Create(UIScaleHealth, downinfo, {Scale = 0.3}):Play()
		SoundEffects.LostHealth:Play()
		task.wait(0.1)
		healthIcon.Image = EmptyHeart
		TweenService:Create(UIScaleHealth, downinfo, {Scale = 1}):Play()
	end

end

function LifesController:RefillClicked()
	Pause = true
	if Player.PrivateStats.Lifes.Value<1 then
		MarketplaceService:PromptProductPurchase(Player,MarketModule.ProductIds['1Life'].Id)
	else
		self.LifeService:LifeRefillEvent():andThen(function(result)
			if not result then
				MarketplaceService:PromptProductPurchase(Player,MarketModule.ProductIds['1Life'].Id)
			else
				if closepopup then
					closepopup()
				end
				bought = true
				Pause = false
			end
		end)
	end
end

function LifesController:KnitStart()
	local ClockService = Knit.GetService('ClockService')
    local GeneralGameplay = Knit.GetService('GeneralGameplay')
	local TargetService = Knit.GetService('TargetService')
    self.LifeService = Knit.GetService('LifeService')

    self:UpdateLifes(LifesValue.Value)
    LifesValue:GetPropertyChangedSignal('Value'):Connect(function()
        self:UpdateLifes(LifesValue.Value)
    end)

    HealthPopupUI:WaitForChild('Buy').MouseButton1Click:Connect(function()
        self:RefillClicked()
    end)

	LifesFrame.RefillLifes.MouseButton1Click:Connect(function()
		self:RefillClicked()
	end)
end


return LifesController

