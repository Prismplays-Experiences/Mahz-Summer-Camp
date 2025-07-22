--> Services
----------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local AnalyticsService = game:GetService("AnalyticsService")

--> Modules
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Signal = require(Packages:WaitForChild("Signal"))
local Knit = require(Packages:WaitForChild("Knit"))

local Info = ReplicatedStorage:WaitForChild("Info")
local InstructorMessages = require(Info:WaitForChild("InstructorMessages"))
local GeneralInfo = require(Info:WaitForChild("GeneralInfo"))

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ChatNotification = require(Modules:WaitForChild("Client"):WaitForChild("ChatNotification"))

--> Assets
----------------------------------------
local ScriptingProperties = workspace:WaitForChild("Game"):WaitForChild("ScriptingProperties")
local Day1Spawn = ScriptingProperties:WaitForChild("Day1Spawns")
local SoundEffects = ReplicatedStorage:WaitForChild("Models"):WaitForChild("SoundEffects")

--> Variables
----------------------------------------
local Testing = false

--> Knit Setup
----------------------------------------
local GeneralGameplay = Knit.CreateService({
	Name = "GeneralGameplay",
	CountdownValue = RunService:IsStudio() and 20 or 30,
	CountdownEnabled = true,
	Client = {
		DisableControls = Knit.CreateSignal(),
		EnableControls = Knit.CreateSignal(),
		UpdateSlots = Knit.CreateSignal(),
		InjuredCount = Knit.CreateProperty(),
		InjuredNotify = Knit.CreateSignal(),
		StopWorkout = Knit.CreateSignal(),
		CountdownValue = Knit.CreateProperty(),
		LockWorkoutMachines = Knit.CreateSignal(),
	},
})

--> Utility Functions
----------------------------------------

function TeleportPlayersToDay1Spawn()
	for _, plr in game.Players:GetPlayers() do
		task.spawn(function()
			plr.Character:PivotTo(Day1Spawn[plr:GetAttribute("BedNumber")].CFrame * CFrame.new(0, 2, 0))
		end)
	end
end

function SendNotification(player, msg, color, duration, reward, sound)
	local Notify = Knit.GetService("NotificationService")
	Notify:SendNotification(player, {
		message = msg,
		color = color or Color3.fromRGB(255, 255, 255),
		duration = duration or 2,
		reward = reward or false,
		sound = sound or SoundEffects.Positive,
	})
end

function LogOnboardingEvent(Player, step, Name)
	AnalyticsService:LogOnboardingFunnelStepEvent(Player, step, Name)
end

--> Main Functions
----------------------------------------
function GeneralGameplay:Countdown(seconds)
	self.Client.CountdownValue:Set(seconds)
	for i = seconds, 1, -1 do
		self.Client.CountdownValue:Set(i)
		task.wait(1)
	end
	self.Client.CountdownValue:Set(0)
end

function GeneralGameplay:KnitStart()
	-- 20
	local InstructorMessageService = Knit.GetService("InstructorMessage")
	self.ClockService = Knit.GetService("ClockService")
	self.BedService = Knit.GetService("BedService")
	self.TargetService = Knit.GetService("TargetService")
	self.StageService = Knit.GetService("StageService")
	self.LifeService = Knit.GetService("LifeService")
	self.KitchenService = Knit.GetService("KitchenService")
	self.EventsService = Knit.GetService("EventsService")

	local EventCount = 1

	for _, player in pairs(Players:GetPlayers()) do
		LogOnboardingEvent(player, 1, "Joined server")
	end

	if self.CountdownEnabled then
		self:Countdown(self.CountdownValue)
	end
	if not Testing then
		self.Client.StopWorkout:FireAll()
		InstructorMessageService:PlayMessage(InstructorMessages.Day1)
		task.wait(31)
		self.BedService:AssignBedNumbers(game.Players:GetPlayers())
		-- task.wait(2)
		-- InstructorMessageService:PlayMessage(InstructorMessages.Day1)
		-- task.wait(8)
		TeleportPlayersToDay1Spawn()
		-- task.wait(14)
		self.TargetService:SetTarget()
		self.ClockService:ResumeClock()
	end
	local function sendtobed()
		self.BedService:SleepPlayers(false, false)
	end

	for _, player in pairs(Players:GetPlayers()) do
		LogOnboardingEvent(player, 2, "Day 1")
	end
	self.ClockService.DayEnded:Connect(function()
		self.ClockService:YieldClock()
		self.Client.StopWorkout:FireAll()
		task.wait(3)

		local EliminatedPlayers = self.LifeService:GetEliminated()
		self.StageService:WeightPlayers(true, false, sendtobed)
		-- if #EliminatedPlayers<=0 then
		--     self.StageService:WeightPlayers(true,false,sendtobed)
		-- else
		--     self.StageService:WeightPlayers(true,false)
		-- self.StageService:Eliminated(true,false,sendtobed)
		-- task.wait(5)
		-- local EliminatedPlayers = self.LifeService:GetEliminated()
		-- for i, player in pairs(EliminatedPlayers) do
		--     self.LifeService.Client.EliminatePlayer:Fire(player)
		-- end
		-- end
		if self.ClockService.Days == GeneralInfo.MaxDays then
			self.StageService:Winners(true)
			task.wait(5)
			local winners = self:GetWinners()
			for _, player in pairs(winners) do
				player.PrivateStats.Currency.Value += GeneralInfo.WinnerReward
			end
			TeleportToLobby()
			return
		end

		task.wait(2)
		self.KitchenService:Clear()
		self.BedService:RisePlayers()
		task.wait(1)
		self:RunInstructorMessage(self.ClockService.Days)
		--
		task.wait(2)
		self.TargetService:SetTarget()

		for _, player in pairs(Players:GetPlayers()) do
			if not player:HasTag("Eliminated") then
				LogOnboardingEvent(player, self.ClockService.Days + 1, "Day " .. self.ClockService.Days)
				player.PrivateStats.Currency.Value += GeneralInfo.RewardPerDay
				SendNotification(
					player,
					`New Day! +{GeneralInfo.RewardPerDay} Coins`,
					Color3.fromRGB(0, 255, 0),
					5,
					false,
					SoundEffects.CoinsSound
				)
			end
		end
		self.ClockService:ResumeClock()
		EventCount += 1
		if EventCount == 3 then
			EventCount = 0
			self.EventsService:EventLoop((self.ClockService.MinutesPerDay / 2) * 60)
		end
	end)
	-- self.EventsService:EventLoop((self.ClockService.MinutesPerDay/2)*60s) --
	-- self.StageService:WeightPlayers(true)
	-- task.wait(10)
	-- self.StageService:WeightPlayers(true)
end

function TeleportToLobby()
	local players = game.Players:GetPlayers()
	local teleportData = {
		PlaceId = GeneralInfo.LobbyPlaceId,
	}
	TeleportService:TeleportPartyAsync(GeneralInfo.LobbyPlaceId, players, teleportData)
end

function GeneralGameplay:GetWinners()
	local winners = {}
	for _, plr in game.Players:GetPlayers() do
		if plr:HasTag("Eliminated") then
			continue
		end
		table.insert(winners, plr)
	end
	return winners
end

function GeneralGameplay:RunInstructorMessage(Day)
	local InstructorMessageService = Knit.GetService("InstructorMessage")
	if Day == 2 then
		InstructorMessageService:PlayMessage(InstructorMessages.Day2)
		task.wait(32.5)
	end
	if Day == 3 then
		InstructorMessageService:PlayMessage(InstructorMessages.Day3)
		task.wait(36)
	end
end

function GeneralGameplay.Client:LoseWeight(Player, Weight)
	local leaderstats = Player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end
	local WeightStat = leaderstats:FindFirstChild("Weight")
	if not WeightStat then
		return
	end
	Weight = math.clamp(WeightStat.Value - Weight, GeneralInfo.EndWeight, GeneralInfo.Weight)
	WeightStat.Value = Weight
	if WeightStat.Value < 0 then
		WeightStat.Value = 0
	end
end

function GeneralGameplay.Client:TagSlot(Player, Slot, Tag)
	if not Slot or not Slot:IsA("BasePart") then
		return
	end
	if Tag then
		Slot:SetAttribute("Owner", Player.Name)
	else
		Slot:SetAttribute("Owner", nil)
	end
	self.UpdateSlots:FireAll()
end

function GeneralGameplay.Client:GiveTool(Player, Tool)
	Tool = Tool:Clone()
	if not Tool or not Tool:IsA("Tool") then
		return
	end
	if Player.Character and Player.Character:FindFirstChild("Humanoid") then
		Player.Character:FindFirstChild("Humanoid"):UnequipTools()
		Tool.Parent = Player.Character
		return Tool
	else
		return nil
	end
end

function GeneralGameplay.Client:RemoveTool(Player, Tool)
	if not Tool or not Tool:IsA("Tool") then
		return
	end
	if Player.Character and Player.Character:FindFirstChild(Tool.Name) then
		Tool:Destroy()
	end
end

function GeneralGameplay.Client:SetInjured(Player, Injured)
	if not Player or not Player:IsA("Player") then
		return
	end
	if Injured then
		self.InjuredNotify:Fire(Player, true)
		Player:SetAttribute("Injured", true)
	else
		Player:SetAttribute("Injured", false)
		self.InjuredNotify:Fire(Player, false)
		Player.Character:FindFirstChild("RecoveryBar"):Destroy()
		return
	end
	self.InjuredCount:SetFor(Player, 35)
	local RecoveryBar = ServerStorage:WaitForChild("Assets"):WaitForChild("RecoveryBar"):Clone()
	local Filler = RecoveryBar:WaitForChild("Bar"):WaitForChild("Fill")
	RecoveryBar.Parent = Player.Character
	while Player:GetAttribute("Injured") and task.wait(1) do
		local Count = self.InjuredCount:GetFor(Player)
		self.InjuredCount:SetFor(Player, Count - 1)
		Filler.Size = UDim2.fromScale(1, 1 - ((Count - 1) / 35))
		if Count - 1 <= 0 then
			Player:SetAttribute("Injured", false)
			self.InjuredNotify:Fire(Player, false)
			RecoveryBar:Destroy()
			break
		end
	end
	self.InjuredCount:SetFor(Player, 0)
end

function GeneralGameplay.Client:GetDays()
	return self.Server.ClockService.Days
end

function GeneralGameplay.Client:PivotCharacter(Player, Character, CFrame)
	Character:PivotTo(CFrame)
end

function GeneralGameplay.Client.TargetReached(Player)
	Player.PrivateStats.Currency.Value += 5
	ChatNotification.new("Server", `{Player.DisplayName} reached their target!`, Color3.fromRGB(0, 255, 0))
end

return GeneralGameplay
