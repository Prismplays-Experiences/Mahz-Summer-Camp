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

--> Main Functions
----------------------------------------

function EventService:EventValidationCheck(Event)
	local MinPlayers = Event.MinPlayers
	local Players = GetPlayersInGame()
	if #Players < MinPlayers then
		return false
	end
	return true
end

function EventService:RandomEvent()
	local Event, EventKey
	repeat
		Event, EventKey = RandomFromDictionary(EventsModules, self.PreviousEventKey)
	until self:EventValidationCheck(Event) and Event

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
		Event:Start()
	end)
end

function EventService:Cleanup()
	self.Client.EventStatus:Set("Event Over")
	if self.Event.LockWorkoutMachines then
		self.GeneralService.Client.LockWorkoutMachines:FireAll(false)
	end
	if self.Event.YieldClock then
		self.ClockService:ResumeClock()
	end
	task.delay(5, function()
		self.Client.EventStatus:Set("")
	end)
	self.Event:Clean()
	self.Event = nil
end

function EventService:EventLoop(ValueDelay)
	for i = 1, ValueDelay do
		self.Client.EventStatus:Set(`Next event in {ValueDelay - i}s`)
		task.wait(1)
	end
	local Event = self:RandomEvent()

	self:StartEvent(Event)
	self.Client.EventStatus:Set(`Event in progress: {Event.Name}`)
end

function EventService:KnitStart()
	self.GeneralService = Knit.GetService("GeneralGameplay")
	self.ClockService = Knit.GetService("ClockService")
	
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
	task.wait(20)
	print("Starting Race Event")
	print(EventsModules)
	EventsModules['Race']:Start()
end

return EventService
