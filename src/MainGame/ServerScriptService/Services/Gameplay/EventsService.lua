--> Services
----------------------------------------
local ServerScriptService = game:GetService("ServerScriptService")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")

local EventsFolder = ServerScriptService:WaitForChild("Services"):WaitForChild("Gameplay"):WaitForChild("Events")

--> Variables
----------------------------------------
local EventsModules = {}
local ValidationMaxAttempts = 30

local EventQueue = {}
local EventMap = {}

--> Knit Setup
----------------------------------------
local EventService = Knit.CreateService({
	Name = "EventsService",
	Client = {
		EventStatus = Knit.CreateProperty(),
		EnableEventsInterfaces = Knit.CreateSignal(),
		SendHardNotification = Knit.CreateSignal(),
	},
})

--> Utility Functions
----------------------------------------

function RandomFromDictionary(dict, previous)
	local keys = {}
	for key in pairs(dict) do
		if key ~= previous then
			table.insert(keys, key)
		end
	end
	if #keys == 0 then
		return nil
	end
	local randomKey = keys[math.random(1, #keys)]
	return dict[randomKey], randomKey
end

function GetPlayersInGame()
	local plrs = {}
	for _, plr in game.Players:GetPlayers() do
		if plr:HasTag("Eliminated") then
			continue
		end
		table.insert(plrs, plr)
	end
	return plrs
end

local function AddToQueue(eventName)
	if not eventName or EventMap[eventName] then
		return
	end
	local position = #EventQueue + 1
	EventQueue[position] = eventName
	EventMap[eventName] = position
end

local function GetFromQueue()
	if #EventQueue == 0 then
		return nil
	end

	local eventName = table.remove(EventQueue, 1)
	EventMap[eventName] = nil

	for i, name in ipairs(EventQueue) do
		EventMap[name] = i
	end

	return eventName
end

--> Main Functions
----------------------------------------

function EventService:EventValidationCheck(Event)
	if Event.Locked then
		return false
	end
	local MinPlayers = Event.MinPlayers
	local Players = GetPlayersInGame()
	if #Players < MinPlayers then
		return false
	end
	return true
end

function EventService:GetEventsQueue()
	return EventQueue
end

function EventService:RandomEvent()
	local QueuedEvent = GetFromQueue()
	if QueuedEvent and self:EventValidationCheck(EventsModules[QueuedEvent]) then
		return EventsModules[QueuedEvent], QueuedEvent
	else
		AddToQueue(QueuedEvent)
	end
	local Event, EventKey

	local Attempts = 0
	repeat
		Attempts += 1
		task.wait(0.1) -- Prevent tight loop
		Event, EventKey = RandomFromDictionary(EventsModules, self.PreviousEventKey)
	until self:EventValidationCheck(Event) and Event or Attempts >= ValidationMaxAttempts
	if Attempts >= ValidationMaxAttempts then
		return nil, nil
	end

	-- self.PreviousEventKey = EventKey
	return Event, EventKey
end

function EventService:StartEvent(Event)
	self.Event = Event
	if self.Event.LockWorkoutMachines then
		self.GeneralService.Client.LockWorkoutMachines:FireAll(true)
	end
	if self.Event.YieldClock then
		self.ClockService:YieldClock()
	end
	self.Client.SendHardNotification:FireAll(self.Event.Details.Text, self.Event.Details.Image)

	Event.Ended:Connect(function()
		self:Cleanup()
	end)
	task.spawn(function()
		self.MusicService:NewSong(self.Event.Music or "EventsMusics")
		Event:Start()
	end)
end

function EventService:Cleanup(msg)
	self.Client.EventStatus:Set(msg or "Event Over")
	self.MusicService:NewSong("Normal")
	task.delay(5, function()
		self.Client.EventStatus:Set("")
	end)
	if self.Event then
		if self.Event.LockWorkoutMachines then
			self.GeneralService.Client.LockWorkoutMachines:FireAll(false)
		end
		if self.Event.YieldClock then
			self.ClockService:ResumeClock()
		end
		self.Event:Clean()
	end
	self.Event = nil
	self.EventCompleted = true
	self.EventCountdown = false
	self.GeneralService.EventInProgress = false
end

function EventService:EventLoop(ValueDelay)
	self.GeneralService.EventInProgress = true
	self.EventCompleted = false
	for i = 1, ValueDelay do
		self.EventCountdown = true
		self.Client.EventStatus:Set(`Next event in {ValueDelay - i}s`)
		task.wait(1)
	end
	local Event = self:RandomEvent()
	if not Event then
		self:Cleanup("No Event found!")
		return
	end
	self:StartEvent(Event)
	self.Client.EventStatus:Set(`Event in progress: {Event.Name}`)
	repeat
		task.wait(1)
	until self.EventCompleted
	return true
end

function EventService:QueueEvent(EventName)
	local TimeLeft = self.ClockService:GetSecondsLeft()
	AddToQueue(EventName)
	if self.EventCountdown then
		return
	end
	if TimeLeft < 15 then
		return
	end
	self:EventLoop(math.round(TimeLeft / 5))
end

function EventService:KnitStart()
	self.GeneralService = Knit.GetService("GeneralGameplay")
	self.ClockService = Knit.GetService("ClockService")
	self.MusicService = Knit.GetService("MusicService")

	for _, event in pairs(EventsFolder:GetChildren()) do
		if not event:IsA("ModuleScript") then
			continue
		end

		local EventModule = Knit.GetService(event.Name) or require(event)

		if EventModule then
			EventsModules[event.Name] = EventModule
		end
	end

	--testing
	-- task.wait(5)
	-- print("Starting Race Event")
	-- print(EventsModules)
	-- EventsModules['Race']:Start()
end

return EventService
