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
local Knit = require("@Packages/Knit")
local InstructorMessages = require("@Info/InstructorMessages")
local ExperienceInfo = require("@Info/ExperienceInfo")
local GeneralInfo = require("@Info/GeneralInfo")

--> Assets
----------------------------------------
local ScriptingProperties = workspace:WaitForChild("Game"):WaitForChild("ScriptingProperties")
local Day1Spawn = ScriptingProperties:WaitForChild("Day1Spawns")
local SoundEffects = ReplicatedStorage:WaitForChild("Models"):WaitForChild("SoundEffects")

--> Variables
----------------------------------------
local Testing = false

local WAITING_TIME_FOR_STUDIO = 10

--> Knit Setup
----------------------------------------
local GeneralGameplay = Knit.CreateService({
	Name = "GeneralGameplay",
	CountdownValue = RunService:IsStudio() and WAITING_TIME_FOR_STUDIO or 30,
	CountdownEnabled = true,
	TargetReachedPlayers = {},
	EventDisplayFrequency = 3,
	EventCompleted = false,
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
function TeleportToLobby()
	for _, Player in Players:GetPlayers() do
		local success, errorMessage = pcall(function()
			TeleportService:Teleport(ExperienceInfo.Places.Lobby.Id, Player)
		end)

		if not success then
			warn("Failed to teleport player to the lobby: " .. errorMessage)
			task.delay(5, function()
				TeleportToLobby()
			end)
		end
	end
end

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
	local InstructorMessageService = Knit.GetService("InstructorMessage")
	self.MessageService = Knit.GetService("MessageService")
	self.ClockService = Knit.GetService("ClockService")
	self.BedService = Knit.GetService("BedService")
	self.TargetService = Knit.GetService("TargetService")
	self.StageService = Knit.GetService("StageService")
	self.LifeService = Knit.GetService("LifeService")
	self.KitchenService = Knit.GetService("KitchenService")
	self.EventsService = Knit.GetService("EventsService")

	self.EventCount = self.EventDisplayFrequency - 1

	for _, player in pairs(Players:GetPlayers()) do
		LogOnboardingEvent(player, 1, "Joined server")
	end

	if self.CountdownEnabled then
		self:Countdown(self.CountdownValue)
	end
	-- task.wait(2)

	-- local event = self.EventsService:RandomEvent()
	-- self.EventsService:StartEvent(event)
	if not Testing then
		self.Client.LockWorkoutMachines:FireAll(true)
		InstructorMessageService:PlayMessage(InstructorMessages.Day1)
		task.wait(31)
		self.BedService:AssignBedNumbers(game.Players:GetPlayers())
		TeleportPlayersToDay1Spawn()
		self.TargetService:SetTarget()
		self.ClockService:ResumeClock()
		self.Client.LockWorkoutMachines:FireAll(false)
	end
	local function sendtobed()
		self.BedService:SleepPlayers(false, false)
	end

	for _, player in pairs(Players:GetPlayers()) do
		LogOnboardingEvent(player, 2, "Day 1")
	end
	self.ClockService.DayEnded:Connect(function()
		self.ClockService:YieldClock()
		self.Client.LockWorkoutMachines:FireAll(true)
		-- self.Client.StopWorkout:FireAll()
		task.wait(3)
		self.TargetReachedPlayers = {}

		if self.ClockService.Days == GeneralInfo.MaxDays + 1 then
			self.StageService:WeightPlayers(true, false)
			self.StageService:Winners(true)
			task.wait(5)
			local winners = self:GetWinners()
			for _, player in pairs(winners) do
				player.PrivateStats.Currency.Value += GeneralInfo.WinnerReward
			end
			TeleportToLobby()
			return
		else
			self.StageService:WeightPlayers(true, false, sendtobed)
		end

		task.wait(2)
		self.KitchenService:Clear()
		self.BedService:RisePlayers()
		task.wait(1)
		self:RunInstructorMessage(self.ClockService.Days)
		--
		task.wait(2)
		self.TargetService:SetTarget()
		self.Client.LockWorkoutMachines:FireAll(false)
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
		self.EventCount += 1
		if self.EventCount == self.EventDisplayFrequency then
			self.EventCount = 0
			self.EventCompleted = self.EventsService:EventLoop((self.ClockService.MinutesPerDay / 2) * 60) --
		else
			if #self.EventsService:GetEventsQueue() > 0 then
				self.EventsService:StartEvent((self.ClockService.MinutesPerDay / 2) * 60)
			else
				-- self.EventInProgress = true
				self.EventCompleted = self.EventsService.Client.EventStatus:Set(
					`Next event: Day{self.ClockService.Days + self.EventDisplayFrequency - self.EventCount}`
				)
				-- self.EventInProgress = false
			end
		end
	end)
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

function GeneralGameplay:RunInstructorMessage()
	-- local InstructorMessageService = Knit.GetService("InstructorMessage")
	-- if Day == 2 then
	-- 	InstructorMessageService:PlayMessage(InstructorMessages.Day2)
	-- 	task.wait(32.5)
	-- end
	-- if Day == 3 then
	-- 	InstructorMessageService:PlayMessage(InstructorMessages.Day3)
	-- 	task.wait(36)
	-- end
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
	local CountVal = 35
	if Player:HasTag("HyperShredMax") then
		CountVal /= 2
	end
	self.InjuredCount:SetFor(Player, CountVal)
	local RecoveryBar = ServerStorage:WaitForChild("Assets"):WaitForChild("RecoveryBar"):Clone()
	local Filler = RecoveryBar:WaitForChild("Bar"):WaitForChild("Fill")
	RecoveryBar.Parent = Player.Character
	while Player:GetAttribute("Injured") and task.wait(1) do
		local Count = self.InjuredCount:GetFor(Player)
		self.InjuredCount:SetFor(Player, Count - 1)
		Filler.Size = UDim2.fromScale(1, 1 - ((Count - 1) / CountVal))
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

function GeneralGameplay.Client:PivotCharacter(_, Character, CFrame)
	Character:PivotTo(CFrame)
end

function GeneralGameplay.Client:TargetReached(Player)
	Player.PrivateStats.Currency.Value += 15
	self.Server.MessageService:SendToAll(
		`🎯 <b>{Player.DisplayName} Has Reached Their Target!</b>`,
		Color3.fromRGB(85, 255, 85),
		"Gotham",
		20
	)
	if (self.Server.EventCount == 0 and not self.Server.EventCompleted) or self.Server.EventInProgress then
		return
	end
	table.insert(self.Server.TargetReachedPlayers, Player)
	if #self.Server.TargetReachedPlayers == #game.Players:GetPlayers() then
		self.Server.ClockService:EndDay()
	end
end

function GeneralGameplay.Client:SetWorkoutStatus(Player, status)
	Player:SetAttribute("WorkoutStatus", status)
end

return GeneralGameplay
