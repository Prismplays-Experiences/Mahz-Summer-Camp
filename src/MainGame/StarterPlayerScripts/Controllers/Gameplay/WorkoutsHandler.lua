--> Services
----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")

--> Assets
----------------------------------------
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Models = ReplicatedStorage:WaitForChild("Models")
local SoundEffects = Models:WaitForChild("SoundEffects")
local ScriptingProperties = Workspace:WaitForChild("Game"):WaitForChild("ScriptingProperties")
local WorkoutEquipments = ScriptingProperties:WaitForChild("WorkoutEquipments")
local ItemsToHide = ScriptingProperties:WaitForChild("ItemsToHide")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main")
local HUD = Main:WaitForChild("HUD")
local InjuryRecoverybtn = HUD:WaitForChild("InjuryRecovery")
local GameplayFrames = Main:WaitForChild("Gameplay")
local WeightLossBtn = GameplayFrames:WaitForChild("WeightLoss")

local ModuleAssets = Main:WaitForChild("ModuleAssets")
local BillboardStorage = ModuleAssets:WaitForChild("Billboards")
local WorkoutBillboards = BillboardStorage:WaitForChild("WorkoutBillboards")

local Confetti = Assets:WaitForChild("Confetti")

--> Modules
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local Trove = require(Packages:WaitForChild("Trove"))
local Modules = ReplicatedStorage:WaitForChild("Modules")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local HardNotification = require(Modules.HardNotification)

local Info = ReplicatedStorage:WaitForChild("Info")
local WorkoutMetaData = require(Info:WaitForChild("WorkoutMetaData"))

local MarketModule = require(Modules:WaitForChild("MarketService"))

-- local WorkoutLabelTemplate = Assets:WaitForChild('WorkoutTemplate')
-- local WorkoutBillboards = ScriptingProperties:WaitForChild('WorkoutBillboards')

local GeneralInfo = require(Info:WaitForChild("GeneralInfo"))

--> Variables
----------------------------------------
local Player = game.Players.LocalPlayer
local LockedCap = Player:WaitForChild("PrivateStats"):WaitForChild("LockedCap")
local Camera = workspace.CurrentCamera
local DefaultFOV = Camera.FieldOfView

local WeightLossIncrements = {
	[1] = nil,
	[1.2] = MarketModule.ProductIds["1.2xWeightLoss"].Id,
	[1.4] = MarketModule.ProductIds["1.4xWeightLoss"].Id,
	[1.6] = MarketModule.ProductIds["1.6xWeightLoss"].Id,
	[1.8] = MarketModule.ProductIds["1.8xWeightLoss"].Id,
	[2] = MarketModule.ProductIds["2xWeightLoss"].Id,
	[2.4] = MarketModule.ProductIds["2.4xWeightLoss"].Id,
	[2.8] = MarketModule.ProductIds["2.8xWeightLoss"].Id,
	[3.2] = MarketModule.ProductIds["3.2xWeightLoss"].Id,
	[4] = MarketModule.ProductIds["4xWeightLoss"].Id,
}

--> Knit Setup
----------------------------------------

local WorkoutsHandler = Knit.CreateController({
	Name = "WorkoutsHandler",
	IsInWorkout = false,
	WorkoutType = "",
	WorkoutData = nil,
	WorkoutTrove = Trove.new(),
	ProximityPrompts = {},
	InjuryLogic = Instance.new("BoolValue"),
})

--> Utility Functions
----------------------------------------
local function GetWeightLossColor(multiplier)
	local keys = {}
	for k in pairs(WeightLossIncrements) do
		table.insert(keys, k)
	end
	table.sort(keys)

	local currentIndex
	for i, k in ipairs(keys) do
		if math.abs(k - multiplier) < 0.01 then
			currentIndex = i
			break
		end
	end

	if not currentIndex then
		return Color3.fromRGB(255, 255, 255)
	end

	local t = (currentIndex - 1) / (#keys - 1)
	t = math.clamp(t, 0, 1)

	local r, g, b

	if t < 0.5 then
		local p = t / 0.5
		r = 255
		g = 255 * p
		b = 0
	else
		local p = (t - 0.5) / 0.5
		r = 255 * (1 - p)
		g = 255
		b = 0
	end

	return Color3.fromRGB(r, g, b)
end

function CheckIfAlive(Plr)
	if not Plr.Character then
		return false
	end
	local char = Plr.Character
	if char then
		if char.Humanoid.Health <= 0 then
			return false
		end
	end
	return true
end

function GetNextWeightLossIncrement(currentMultiplier, increments)
	local keys = {}

	-- Collect and sort keys
	for k in pairs(increments) do
		table.insert(keys, k)
	end
	table.sort(keys)

	-- Find next higher key
	for i = 1, #keys do
		if keys[i] > currentMultiplier then
			local nextKey = keys[i]
			return nextKey, increments[nextKey]
		end
	end

	-- No next value (already at max)
	return nil, nil
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

function SetModelTransparency(Model, Transparency)
	for _, v in Model:GetDescendants() do
		if v:IsA("BasePart") or v:IsA("MeshPart") then
			v.Transparency = Transparency
		end
	end
end

function SplitByCapitalLetters(input)
	local result = {}
	local currentWord = ""
	for i = 1, #input do
		local char = input:sub(i, i)
		if char:match("%u") and #currentWord > 0 then
			table.insert(result, currentWord)
			currentWord = char
		else
			currentWord = currentWord .. char
		end
	end
	if #currentWord > 0 then
		table.insert(result, currentWord)
	end
	return table.concat(result, " ")
end

--> Main Functions
----------------------------------------

function ShortNotification(Text, TextColor, Random)
	local NotificationTemplete = Confetti:WaitForChild("ShortNotification"):Clone()
	local randomx = math.random(25, 85) / 100
	local randomy = math.random(35, 85) / 100
	if Random then
		NotificationTemplete.Position = UDim2.fromScale(randomx, randomy)
	end

	local UIStroke = NotificationTemplete:WaitForChild("UIStroke")
	NotificationTemplete.Text = Text
	NotificationTemplete.TextColor3 = TextColor or Color3.fromRGB(255, 255, 255)
	NotificationTemplete.Visible = false
	NotificationTemplete.Parent = Player.PlayerGui:WaitForChild("Main"):WaitForChild("Gameplay")
	local tweeninstroke = TweenService:Create(UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { Transparency = 0 })
	local tweenintext =
		TweenService:Create(NotificationTemplete, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { TextTransparency = 0 })
	local tweentextpos = TweenService:Create(
		NotificationTemplete,
		TweenInfo.new(1.6, Enum.EasingStyle.Quad),
		{ Position = UDim2.fromScale(randomx, randomy - 0.35) }
	)
	local tweenoutstroke =
		TweenService:Create(UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { Transparency = 1 })
	local tweenouttext =
		TweenService:Create(NotificationTemplete, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { TextTransparency = 1 })
	tweeninstroke:Play()
	tweentextpos:Play()
	tweenintext:Play()
	NotificationTemplete.Visible = true
	task.wait(0.5)
	tweenoutstroke:Play()
	tweenouttext:Play()
	tweenouttext.Completed:Connect(function()
		NotificationTemplete:Destroy()
	end)
end

function WorkoutsHandler:PlayMinigame(Minigame, Level)
	return Minigame:Start(Level)
end

function WorkoutsHandler:RunInjuryLogic()
	self.InjuryLogic:GetPropertyChangedSignal("Value"):Connect(function()
		if self.InjuryLogic.Value == false then
			return
		end
		self.GeneralService
			:GetDays()
			:andThen(function(Days)
				local maxBase = 35
				local randomFactor = math.random(80, 120) / 100
				local InjuryTime = math.clamp(math.floor((maxBase / Days) * randomFactor), 1, maxBase)
				print("Injury Time:", InjuryTime)
				self.Injured = false
				for i = 1, InjuryTime do
					task.wait(1)
					if not self.InjuryLogic.Value then
						return
					end
					if i >= InjuryTime then
						self.Injured = true
					end
				end
				if not self.Injured then
					return
				end
				self:StopWorkout()
				self.GeneralService:SetInjured(true)
			end)
			:await()
	end)
end

function WorkoutsHandler:ControlProximityPrompts(Enabled)
	if Enabled and self.Injured then
		return
	end
	local CurrentDay
	self.GeneralService
		:GetDays()
		:andThen(function(val)
			CurrentDay = val
		end)
		:await()
	for _, prompt in pairs(self.ProximityPrompts) do
		local WorkoutType = prompt.Parent.Parent.Name
		local unlockDay = GeneralInfo.WorkoutStartDays[WorkoutType].Day

		-- print('UnlockDay:', unlockDay, 'CurrentDay:', CurrentDay, 'LockedCap:', LockedCap.Value)
		if CurrentDay < unlockDay and LockedCap.Value < unlockDay then
			prompt.Enabled = false
			continue
		end
		if Enabled then
			if prompt.Parent:GetAttribute("Owner") ~= nil then
				prompt.Enabled = false
			else
				prompt.Enabled = true
			end
		else
			prompt.Enabled = false
		end
	end

	for i, billboard in WorkoutBillboards:GetChildren() do
		local unlockDay = GeneralInfo.WorkoutStartDays[billboard.Name].Day
		if CurrentDay < unlockDay and LockedCap.Value < unlockDay then
			billboard.Enabled = true
		else
			billboard.Enabled = false
		end
		local LevelTxt = billboard:WaitForChild("Level")
		LevelTxt.TextColor3 = GeneralInfo.WorkoutStartDays[billboard.Name].LevelColor
		LevelTxt.Text = `Day {GeneralInfo.WorkoutStartDays[billboard.Name].Day}`
		billboard:WaitForChild("WorkoutName").Text = SplitByCapitalLetters(billboard.Name)
	end
end

function WorkoutsHandler:StartWorkout(slot, Data)
	self.InWorkout = true
	if slot:GetAttribute("Owner") then
		return
	end
	self.MusicController:PlayNewSong("Workout")
	self.GeneralService:TagSlot(slot, true)
	self.TaggedSlot = slot
	local WorkoutName = slot.Parent.Name
	HUD:WaitForChild("TargetWeight").Visible = true
	HUD:WaitForChild("LifesFrame").Visible = false
	GameplayFrames.Visible = true
	self:ControlProximityPrompts(false)
	pcall(function()
		self.GeneralController.PlayerModule:Disable()
	end)

	local Character = Player.Character
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local HRP = Character:FindFirstChild("HumanoidRootPart")
	HRP.Anchored = true
	self.GeneralService:PivotCharacter(Character, slot:WaitForChild("PlayerPosition").CFrame)
	-- Character:PivotTo(slot:WaitForChild('PlayerPosition').CFrame)
	Humanoid.WalkSpeed = 0
	Humanoid.JumpPower = 0
	if Data.Tool then
		self.GeneralService
			:GiveTool(Data.Tool)
			:andThen(function(Tool)
				self.WorkoutTool = Tool
			end)
			:await()
	end
	if ItemsToHide:FindFirstChild(WorkoutName) then
		local ItemToHide = ItemsToHide[WorkoutName]
		SetModelTransparency(ItemToHide, 1)
	end
	Data.AnimTrack:Play()
	self.CurrentTrack = Data.AnimTrack
	self.MinigameData = self:PlayMinigame(self.Minigames[Data.Minigame], Data.Level)
	Data.AnimTrack:AdjustSpeed(0)
	self.WorkoutValueEvent = self.MinigameData.Value:GetPropertyChangedSignal("Value"):Connect(function()
		if self.MinigameData.Value == nil then
			return
		end
		Data.AnimTrack:AdjustSpeed(self.MinigameData.Value.Value)
	end)
	self.StoppedEvent = self.MinigameData.Stopped:Connect(function()
		self:StopWorkout()
	end)
	self.FailedEvent = self.MinigameData.Failed:Connect(function(boolean)
		if self.Injured then
			return
		end
		self.InjuryLogic.Value = boolean
	end)
	self.AnimTrackSignal = Data.AnimTrack:GetMarkerReachedSignal("RepCount"):Connect(function(param)
		self:LoseWeight(math.random(Data.MinWeightLoss, Data.MaxWeightLoss))
	end)
end

function WorkoutsHandler:LoseWeight(Value)
	if Player:HasTag("DoubleWeightLoss") then
		Value = Value * 2
	end
	local WeightLossMultiplier = Player:GetAttribute("WeightLossMultiplier") or 1
	local suffix = ""
	if WeightLossMultiplier > 1 then
		Value = Value * WeightLossMultiplier
		suffix = ` ({WeightLossMultiplier}x)`
	end
	ShortNotification(`-{Value}{suffix} lbs`, Color3.fromRGB(255, 209, 57), true)
	self.GeneralService:LoseWeight(Value)
end

function WorkoutsHandler:StopWorkout()
	if not self.InWorkout then
		return
	end
	self.MusicController:PlayNewSong("Normal")
	self.InWorkout = false
	self.InjuryLogic.Value = false
	GameplayFrames.Visible = false
	HUD:WaitForChild("TargetWeight").Visible = false
	HUD:WaitForChild("LifesFrame").Visible = true
	pcall(function()
		self.GeneralController.PlayerModule:Enable()
	end)

	local WorkoutName = self.TaggedSlot.Parent.Name
	if ItemsToHide:FindFirstChild(WorkoutName) then
		local ItemToHide = ItemsToHide[WorkoutName]
		SetModelTransparency(ItemToHide, 0)
	end
	self.CurrentTrack:Stop()
	self.StoppedEvent:Disconnect()
	self.MinigameData.Stop:Fire()
	self.WorkoutValueEvent:Disconnect()
	self.FailedEvent:Disconnect()
	self.AnimTrackSignal:Disconnect()
	self.GeneralService:TagSlot(self.TaggedSlot, false)
	local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
	Humanoid.WalkSpeed = 16
	Humanoid.JumpPower = 50
	local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
	HRP.Anchored = false
	if self.WorkoutTool then
		self.GeneralService:RemoveTool(self.WorkoutTool)
	end
	self:ControlProximityPrompts(true)
	if not self.TaggedSlot.Parent:GetAttribute("Owner") then
		self.TaggedSlot:FindFirstChild("ProximityPrompt").Enabled = true
	end
end

function WorkoutsHandler:InitialiseWorkouts()
	for _, workout in WorkoutEquipments:GetChildren() do
		local workoutdata = WorkoutMetaData[workout.Name]
		for index, slot in workout:GetChildren() do
			local ProximityPrompt = Instance.new("ProximityPrompt")
			table.insert(self.ProximityPrompts, ProximityPrompt)
			ProximityPrompt.ActionText = workoutdata.ActionText
			ProximityPrompt.ObjectText = workoutdata.ObjectText
			ProximityPrompt.RequiresLineOfSight = false
			ProximityPrompt.Parent = slot
			ProximityPrompt.Triggered:Connect(function()
				if self.MachineLocked then
					SoundEffects.UIDeny:Play()
					SendNotification(
						"Workout Machines are locked!",
						Color3.fromRGB(255, 0, 0),
						2,
						false,
						SoundEffects.UIDeny
					)
					return
				end
				if self.Injured then
					SendNotification(
						"You are injured! Recover first!",
						Color3.fromRGB(255, 0, 0),
						2,
						false,
						SoundEffects.UIDeny
					)
					return
				end
				if slot:GetAttribute("Owner") then
					SoundEffects.UIDeny:Play()
					return
				end
				if self.Cooldown then
					SoundEffects.UIDeny:Play()
					return
				end
				self.Cooldown = true
				self:StartWorkout(slot, workoutdata)
				task.delay(5, function()
					self.Cooldown = false
				end)
			end)
		end
	end
end

function CharacterAdded(Character)
	for i, v in WorkoutMetaData do
		if v.AnimationId then
			local Animation = Instance.new("Animation")
			Animation.AnimationId = v.AnimationId
			v.AnimTrack = Character.Humanoid.Animator:LoadAnimation(Animation)
		end
	end
end

function WorkoutsHandler:KnitStart()
	--controllers
	self.GeneralController = Knit.GetController("GeneralControllers")
	self.GeneralService = Knit.GetService("GeneralGameplay")
	self.MusicController = Knit.GetController("MusicController")

	--load minigames
	local Gameplay = script.Parent
	local WorkoutMinigames = Gameplay:WaitForChild("WorkoutMinigames"):WaitForChild("Minigames")
	self.Minigames = {}
	for i, Minigame in pairs(WorkoutMinigames:GetChildren()) do
		if Minigame:IsA("ModuleScript") then
			local MinigameModule = Knit.GetController(Minigame.Name .. "Minigame")
			self.Minigames[Minigame.Name] = MinigameModule
		end
	end
	self:InitialiseWorkouts()

	-- initialise character
	if CheckIfAlive(Player) then
		CharacterAdded(Player.Character)
	end

	Player.CharacterAdded:Connect(CharacterAdded)

	self.GeneralService.UpdateSlots:Connect(function(Slots)
		if self.CurrentTrack then
			return
		end
		for _, v in self.ProximityPrompts do
			if v.Parent:GetAttribute("Owner") then
				v.Enabled = false
			end
		end
		self:ControlProximityPrompts(true)
	end)

	self.GeneralService.InjuredNotify:Connect(function(Injured)
		if Injured then
			InjuryRecoverybtn.Visible = true
			local InjuryMessage = "You got injured!"
			HardNotification.Send(Player, InjuryMessage, "🤕", SoundEffects.NegativeCartoon)
		else
			self.Injured = false
			InjuryRecoverybtn.Visible = false
			local RecoveryMessage = "Recovered from Injury!"
			HardNotification.Send(Player, RecoveryMessage, "💪", SoundEffects.TreasureCollect)
		end
	end)

	InjuryRecoverybtn.MouseButton1Click:Connect(function()
		MarketplaceService:PromptProductPurchase(Players.LocalPlayer, MarketModule.ProductIds.InjuryRecovery.Id) -- Replace with actual product ID for injury recovery
	end)

	for i, billboard in WorkoutBillboards:GetChildren() do
		if GeneralInfo.WorkoutStartDays[billboard.Name].Day < 2 then
			continue
		end
		local UnlockIndex = GeneralInfo.WorkoutStartDays[billboard.Name].UnlockIndex
		local BuyNow = billboard:WaitForChild("UnlockNow")
		BuyNow:WaitForChild("Amount").Text = `Unlock Now({MarketModule.ProductIds[UnlockIndex].Price}R$)`
		BuyNow.MouseButton1Click:Connect(function()
			if not UnlockIndex then
				return
			end
			MarketplaceService:PromptProductPurchase(Players.LocalPlayer, MarketModule.ProductIds[UnlockIndex].Id)
		end)
	end
	self:RunInjuryLogic()

	self:ControlProximityPrompts(false)
	-- task.wait(5)
	-- self:PlayMinigame(Minigames.ObjectValues,2)

	self.GeneralService.StopWorkout:Connect(function()
		if self.InWorkout then
			self:StopWorkout()
		end
	end)

	LockedCap:GetPropertyChangedSignal("Value"):Connect(function()
		self:ControlProximityPrompts(true)
	end)

	self.GeneralService.LockWorkoutMachines:Connect(function(status)
		if status then
			self.MachineLocked = status
			if self.InWorkout then
				self:StopWorkout()
			end
			self:ControlProximityPrompts(false)
		else
			self.MachineLocked = status
		end
	end)

	self:ControlProximityPrompts(true)

	WeightLossBtn.MouseButton1Click:Connect(function()
		local currentWeightLoss = Player:GetAttribute("WeightLossMultiplier") or 1
		local nextWeightLoss, productId = GetNextWeightLossIncrement(currentWeightLoss, WeightLossIncrements)
		if WeightLossIncrements[nextWeightLoss] then
			MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productId)
		else
			SendNotification(
				"Maximum weight loss multiplier reached!",
				Color3.fromRGB(255, 0, 0),
				2,
				false,
				SoundEffects.UIDeny
			)
		end
	end)

	local function WeightLossMultiplierChanged()
		local currentWeightLoss = Player:GetAttribute("WeightLossMultiplier") or 1
		local nextWeightLoss, productId = GetNextWeightLossIncrement(currentWeightLoss, WeightLossIncrements)
		WeightLossBtn:WaitForChild("Amount").Text = `{nextWeightLoss}x Weight Loss`
		WeightLossBtn.BackgroundColor3 = GetWeightLossColor(nextWeightLoss)
		if currentWeightLoss >= 4 then
			WeightLossBtn.Visible = false
		else
			WeightLossBtn.Visible = true
		end
	end

	Player:GetAttributeChangedSignal("WeightLossMultiplier"):Connect(WeightLossMultiplierChanged)
	WeightLossMultiplierChanged()
	self:ControlProximityPrompts(false)
end

return WorkoutsHandler
