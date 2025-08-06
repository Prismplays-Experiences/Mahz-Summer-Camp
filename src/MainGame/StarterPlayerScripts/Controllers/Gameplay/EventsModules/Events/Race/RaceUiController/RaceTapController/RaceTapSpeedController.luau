local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Knit = require("@Packages/Knit")
local types = require("@Controllers/Gameplay/EventsModules/Events/Race/types")
local RaceInfo = require("@Info/Events/RaceInfo")
local Fusion = require("@Packages/Fusion")
local Trove = require("@Packages/Trove")

local peek = Fusion.peek

type RaceTapSpeedController = types.RaceTapSpeedController

local START_SPEED = RaceInfo.tapSpeed.startSpeed
local SPEED_LOSE_PER_SECOND = RaceInfo.tapSpeed.speedLosePerSecond
local SPEED_PER_TAP = RaceInfo.tapSpeed.speedPerTap
local MAX_SPEED = RaceInfo.tapSpeed.maxSpeed
local SPEED_SPRING_DAMPING = RaceInfo.tapSpeed.speedSpringDamping
local SPEED_SPRING_SPEED = RaceInfo.tapSpeed.speedSpringSpeed

local RaceTapSpeedController = Knit.CreateController { Name = "RaceTapSpeedController" }

function RaceTapSpeedController.KnitInit(self: RaceTapSpeedController)
	self:_setProperties()
end

function RaceTapSpeedController.Start(self: RaceTapSpeedController)
	self:_setSpeed(START_SPEED)
	self:_connectEvents()
end

function RaceTapSpeedController.Stop(self: RaceTapSpeedController)
	self:_cleanTrove()
end

function RaceTapSpeedController.Observe(self: RaceTapSpeedController, callback: (number) -> ()): ()
	local observer = self:_getObserver()
	local trove = self:_getTrove()

	local observeConnection = observer:onChange(function()
		local speed = self:GetSpeedSpring()
		local speedNumber = peek(speed)

		callback(speedNumber)
	end)
	trove:Add(observeConnection)
end

function RaceTapSpeedController.GetSpeed(self: RaceTapSpeedController): Fusion.Value<number>
	return self._speed
end

function RaceTapSpeedController.GetSpeedSpring(self: RaceTapSpeedController): Fusion.Spring<number>
	return self._speedSpring
end

function RaceTapSpeedController._setProperties(self: RaceTapSpeedController)
	self._scope = Fusion.scoped({Value = Fusion.Value, Spring = Fusion.Spring, Observer = Fusion.Observer})
	self._trove = Trove.new()

	self._speed = self._scope:Value(START_SPEED)
	self._speedSpring = self._scope:Spring(self._speed, SPEED_SPRING_SPEED, SPEED_SPRING_DAMPING)
	self._speedSpringObserver = self._scope:Observer(self._speedSpring)
end

function RaceTapSpeedController._connectEvents(self: RaceTapSpeedController)
	local trove = self:_getTrove()
	local currentTime = 0

	trove:Connect(UserInputService.InputBegan, function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.Gamepad1 then
			self:_addSpeed(SPEED_PER_TAP)
		end
	end)

	trove:Connect(RunService.Heartbeat, function(deltaTime: number)
		currentTime = currentTime + deltaTime

		if currentTime < 1 then
			return
		end

		currentTime = 0

		self:_addSpeed(-SPEED_LOSE_PER_SECOND)
	end)
end

function RaceTapSpeedController._addSpeed(self: RaceTapSpeedController, additionalSpeed: number)
	local speed = self:GetSpeed()
	
	local oldSpeed = peek(speed)
	local newSpeed = math.clamp(oldSpeed + additionalSpeed, 0, MAX_SPEED)

	speed:set(newSpeed)
end

function RaceTapSpeedController._cleanTrove(self: RaceTapSpeedController)
	local trove = self:_getTrove()

	trove:Clean()
end

function RaceTapSpeedController._getTrove(self: RaceTapSpeedController)
	return self._trove
end

function RaceTapSpeedController._getObserver(self: RaceTapSpeedController): Fusion.Observer
	return self._speedSpringObserver
end

function RaceTapSpeedController._setSpeed(self: RaceTapSpeedController, speed: number)
	local currentSpeed = self:GetSpeed()

	currentSpeed:set(speed)
end

return RaceTapSpeedController
