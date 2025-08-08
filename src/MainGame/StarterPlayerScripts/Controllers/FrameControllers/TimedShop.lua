--> Services
----------------------------------------
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")
local Trove = require("@Packages/Trove")
local IAPDATA = require("@Info/IAPDATA")
local MarketModule = require("@Modules/MarketService")

--> Assets
----------------------------------------
local Models = ReplicatedStorage:WaitForChild("Models")
local SoundEffects = Models:WaitForChild("SoundEffects")

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main")
local Frames = Main:WaitForChild("Frames")
local MainFrame = Frames:WaitForChild("TimedShop")
local MainContainer = MainFrame:WaitForChild("Container")
local UseSupplimentBtn = Main:WaitForChild("Core"):WaitForChild("UseSuppliment")
local EquipAuraBtn = Main:WaitForChild("Core"):WaitForChild("EquipAura")
local RefreshShopButton = MainFrame:WaitForChild("RefreshShop")

local ShopTemplate = PlayerGui:WaitForChild("Templates"):WaitForChild("ItemTemplate")
local TimeLeftText = MainFrame:WaitForChild("Header"):WaitForChild("Time")

--> Variables
----------------------------------------
local TopButtonsPos = {}

local ObjectsShopTrove = Trove.new()
local ShopRefreshTime = 5 * 60

local GenerationData = {
	Suppliments = 3,
	Events = 3,
	Auras = 3,
}

local CloseSizes = {
	Item = UDim2.fromScale(1, 1),
	PurchaseFrame = UDim2.fromScale(0.8, 0.35),
	ItemFrame = UDim2.fromScale(0.95, 0.3),
}

local OpenSizes = {
	Item = UDim2.fromScale(1, 0.6),
	PurchaseFrame = UDim2.fromScale(0.8, 0.35),
	ItemFrame = UDim2.fromScale(0.95, 0.5),
}

local RarityColors = {
	Common = Color3.fromRGB(200, 200, 200), -- Light Gray
	Uncommon = Color3.fromRGB(80, 200, 120), -- Green
	Rare = Color3.fromRGB(70, 130, 255), -- Blue
	Epic = Color3.fromRGB(180, 70, 255), -- Purple
	Legendary = Color3.fromRGB(255, 170, 0), -- Gold/Orange
	Mythic = Color3.fromRGB(255, 60, 60), -- Red
}

--> Knit Setup
----------------------------------------
local TimedShop = Knit.CreateController({
	Name = "TimedShop",
})

--> Utility Functions
----------------------------------------
function SpinEffect(Model, RotationSpeed)
	local Connection
	local pivotCFrame = Model:GetPivot()

	Connection = RunService.Stepped:Connect(function(_, deltaTime)
		local rotation = CFrame.Angles(0, math.rad(RotationSpeed * deltaTime), 0)
		pivotCFrame = pivotCFrame * rotation
		Model:PivotTo(pivotCFrame)
	end)

	return function()
		if Connection then
			Connection:Disconnect()
			Connection = nil
		end
	end
end

function getPlatform()
	if UserInputService.TouchEnabled then
		return "Mobile"
	end
	if UserInputService.KeyboardEnabled then
		return "Pc"
	end
	return "Console"
end

function SetFrameCanvasPositions()
	TopButtonsPos["Suppliments"] = Vector2.new(
		MainContainer.CanvasPosition.X,
		GetCanvasPosition(MainContainer, MainContainer:WaitForChild("Suppliments")).Y
	)
	TopButtonsPos["Events"] = Vector2.new(
		MainContainer.CanvasPosition.X,
		GetCanvasPosition(MainContainer, MainContainer:WaitForChild("EventsHeading")).Y
	)
	TopButtonsPos["Auras"] = Vector2.new(
		MainContainer.CanvasPosition.X,
		GetCanvasPosition(MainContainer, MainContainer:WaitForChild("AurasHeading")).Y
	)
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

function GenerateRandomItems(data)
	local selected = {}

	for category, amount in pairs(data) do
		local sourceTable = IAPDATA[category]
		if not sourceTable then
			continue
		end

		local availableKeys = {}
		for key in pairs(sourceTable) do
			table.insert(availableKeys, key)
		end

		local count = math.min(amount, #availableKeys)
		local picked = {}

		while #picked < count do
			local index = math.random(1, #availableKeys)
			local key = availableKeys[index]

			table.insert(picked, sourceTable[key])

			table.remove(availableKeys, index)
		end

		selected[category] = picked
	end
	return selected
end

function GetCanvasPosition(scroller, DesiredFrame)
	local difference = DesiredFrame.AbsolutePosition - scroller.AbsolutePosition
	return scroller.CanvasPosition + difference
end

function OpenItemFrame(Obj)
	for _, v in Obj.Parent:GetChildren() do
		if v:IsA("GuiObject") and v ~= Obj then
			CloseItemFrame(v)
		end
	end
	Obj.Item.Size = OpenSizes.Item
	Obj.PurchaseFrame.Size = OpenSizes.PurchaseFrame
	Obj.Size = OpenSizes.ItemFrame
	Obj.PurchaseFrame.Position = UDim2.fromScale(0.5, 0.65)
	Obj.PurchaseFrame.Visible = true
	if Obj:HasTag("LastItem") and Obj.Parent.Name == "Suppliments" then
		repeat
			task.wait()
			MainContainer:WaitForChild("UIListLayout").Padding = UDim.new(0.25, 0)
		until MainContainer:WaitForChild("UIListLayout").Padding == UDim.new(0.25, 0)
	end

	if not Obj:HasTag("LastItem") or (Obj:HasTag("LastItem") and Obj.Parent.Name == "Suppliments") then
		TweenService:Create(
			MainFrame:WaitForChild("Container"),
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				CanvasPosition = Vector2.new(MainContainer.CanvasPosition.X, GetCanvasPosition(MainContainer, Obj).Y),
			}
		):Play()
	end
end

function CloseItemFrame(Obj)
	Obj.PurchaseFrame.Visible = false
	Obj.Item.Size = CloseSizes.Item
	Obj.PurchaseFrame.Size = CloseSizes.PurchaseFrame
	Obj.Size = CloseSizes.ItemFrame
	MainContainer:WaitForChild("UIListLayout").Padding = UDim.new(0.05, 0)
end

local function ToMinutes(seconds)
	seconds = tonumber(seconds) or 0
	local mins = math.floor(seconds / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%02d:%02d", mins, secs)
end

--> Main Functions
----------------------------------------

function TimedShop:PurchaseItem(Price, ProductId, ItemData, Category)
	if Price then
		self.IAPFunction:Purchase(Price, ItemData, Category):andThen(function(result, err)
			if result then
				SendNotification("Item Bought!", Color3.fromRGB(121, 255, 49), 2, false, SoundEffects.Positive)
			else
				SendNotification(err or "Purchase failed", Color3.fromRGB(255, 0, 0), 2, false, SoundEffects.UIDeny)
			end
		end)
	end
	if ProductId then
		local signal
		signal = MarketplaceService.PromptProductPurchaseFinished:Connect(function(userid, productId, wasPurchased)
			if userid == Player.UserId and productId == ProductId and wasPurchased then
				self.IAPFunction:GiveItem(ItemData, Category)
				SendNotification("Item Bought!", Color3.fromRGB(121, 255, 49), 2, true, SoundEffects.Positive)
			end
			signal:Disconnect()
		end)
		MarketplaceService:PromptProductPurchase(Player, ProductId)
	end
end

function TimedShop:InitSupplimentUse()
	Player.Backpack.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") and IAPDATA.Suppliments[tool.Name] then
			tool.Equipped:Connect(function()
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
end

function TimedShop:InitAuraUse()
	Player.Backpack.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") and IAPDATA.Auras[tool.Name] then
			tool.Equipped:Connect(function()
				self.CurrentAura = tool.Name
				if self.EquippedAura == self.CurrentAura then
					EquipAuraBtn:WaitForChild("Amount").Text = "Unequip"
					EquipAuraBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
				else
					EquipAuraBtn:WaitForChild("Amount").Text = "Equip"
					EquipAuraBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
				end
				EquipAuraBtn.Visible = true
			end)
			tool.Unequipped:Connect(function()
				self.CurrentAura = nil
				EquipAuraBtn.Visible = false
			end)
		end
	end)
	local db = false
	EquipAuraBtn.MouseButton1Click:Connect(function()
		if db then
			return
		end
		db = true
		task.delay(0.5, function()
			db = false
		end)
		if self.CurrentAura == self.EquippedAura then
			self.EquippedAura = nil
			EquipAuraBtn:WaitForChild("Amount").Text = "Equip"
			EquipAuraBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			self.AurasService:EquipAura(nil)
		else
			self.EquippedAura = self.CurrentAura
			EquipAuraBtn:WaitForChild("Amount").Text = "Unequip"
			EquipAuraBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			self.AurasService:EquipAura(self.CurrentAura)
		end
	end)
end

function TimedShop:RefreshShop()
	ObjectsShopTrove:Clean()
	local NewItems = GenerateRandomItems(GenerationData)
	for i, Data in NewItems do
		local CategoryFrame = MainFrame:WaitForChild("Container"):WaitForChild(i)
		for Index, ItemData in ipairs(Data) do
			local ItemClone = ShopTemplate:Clone()
			local ItemFrame = ItemClone:WaitForChild("Item")
			local PurchaseFrame = ItemClone:WaitForChild("PurchaseFrame")
			ItemClone.Name = ItemData.Name
			ItemFrame.ItemName.Text = ItemData.Name
			ItemFrame.Cash.Text = "$" .. ItemData.Cost or "N/A"
			ItemFrame.Rarity.Text = ItemData.Rarity or "N/A"
			ItemFrame.Description.Text = ItemData.Description or "N/A"
			ItemFrame.ImageHolder.ImageLabel.Image = ItemData.Image
			if RarityColors[ItemData.Rarity] == nil then
				print(RarityColors[ItemData.Rarity], ItemData.Rarity, ItemData)
			end
			if Index == GenerationData[i] then
				ItemClone:AddTag("LastItem")
			end

			ItemFrame.Rarity.BackgroundColor3 = RarityColors[ItemData.Rarity]

			pcall(function()
				local ProductInfo = MarketplaceService:GetProductInfo(ItemData.ProductId or 0, Enum.InfoType.Product)
				PurchaseFrame.Robux.Text = `{ProductInfo.PriceInRobux} Robux`
				PurchaseFrame.Cash.Text = `${ItemData.Cost or "N/A"}`
			end)

			local ItemTrove = Trove.new()

			ItemTrove:Connect(PurchaseFrame:WaitForChild("Cash").MouseButton1Click, function()
				self:PurchaseItem(ItemData.Cost, nil, ItemData, CategoryFrame.Name)
			end)
			ItemTrove:Connect(PurchaseFrame:WaitForChild("Robux").MouseButton1Click, function()
				self:PurchaseItem(nil, ItemData.ProductId, ItemData, CategoryFrame.Name)
			end)

			CloseItemFrame(ItemClone)
			ItemClone.Parent = CategoryFrame

			ItemTrove:Connect(ItemClone.MouseButton1Click, function()
				if ItemClone.PurchaseFrame.Visible then
					CloseItemFrame(ItemClone)
				else
					OpenItemFrame(ItemClone)
				end
			end)
			ObjectsShopTrove:Add(ItemClone)
			ItemClone.Visible = true
		end
	end
end

function TimedShop:KnitStart()
	self.IAPFunction = Knit.GetService("IAPFunction")
	self.SupplimentsService = Knit.GetService("SupplimentsService")
	self.AurasService = Knit.GetService("AurasService")

	self:InitSupplimentUse()
	self:InitAuraUse()

	self:RefreshShop()
	SetFrameCanvasPositions()

	for _, v in MainFrame:WaitForChild("Categories"):GetChildren() do
		if v:IsA("GuiButton") then
			v.MouseButton1Click:Connect(function()
				SetFrameCanvasPositions()
				TweenService:Create(MainContainer, TweenInfo.new(0.7), {
					CanvasPosition = TopButtonsPos[v.Name],
				}):Play()
			end)
		end
	end

	RefreshShopButton.MouseButton1Click:Connect(function()
		MarketplaceService:PromptProductPurchase(Player, MarketModule.ProductIds.RefreshShop.Id)
	end)

	MarketplaceService.PromptProductPurchaseFinished:Connect(function(userid, productId, wasPurchased)
		if userid == Player.UserId and productId == MarketModule.ProductIds.RefreshShop.Id and wasPurchased then
			self:RefreshShop()
			self.ShouldRestart = true
			SendNotification("Shop refreshed!", Color3.fromRGB(121, 255, 49), 2, true, SoundEffects.Positive)
		end
	end)

	-- local platform = getPlatform()
	-- if platform == "Mobile" then
	-- 	MainContainer.ScrollingEnabled = false
	-- end

	while task.wait(1) do
		local i = 0
		while i < ShopRefreshTime do
			local t = ShopRefreshTime - i
			self.RefreshTimeLeft = t
			TimeLeftText.Text = "New items in: " .. ToMinutes(t)
			task.wait(1)
			if self.ShouldRestart then
				i = 0
				self.ShouldRestart = false
			else
				i += 1
			end
		end

		self:RefreshShop()
	end
end

--> Workspace Effects

local ScriptingProperties = game.Workspace:WaitForChild("Game"):WaitForChild("ScriptingProperties")
local Cosmetics = ScriptingProperties:WaitForChild("Cosmetics")
local CosmeticsRig = Cosmetics:WaitForChild("Rig")
local RotatingBorder = Cosmetics:WaitForChild("Outline")

local IdleAnim = Instance.new("Animation")
IdleAnim.AnimationId = "http://www.roblox.com/asset/?id=507766388"
local IdleTrack = CosmeticsRig:WaitForChild("Humanoid"):LoadAnimation(IdleAnim)
IdleTrack:Play()
IdleTrack.Looped = true

local WaveAnim = Instance.new("Animation")
WaveAnim.AnimationId = "http://www.roblox.com/asset/?id=507770239"
local WaveTrack = CosmeticsRig:WaitForChild("Humanoid"):LoadAnimation(WaveAnim)
WaveTrack.Priority = Enum.AnimationPriority.Action

task.spawn(function()
	while task.wait(7) do
		WaveTrack:Play()
		WaveTrack.Looped = false
		WaveTrack:AdjustSpeed(0.85)
	end
end)

SpinEffect(RotatingBorder, 20)

return TimedShop
