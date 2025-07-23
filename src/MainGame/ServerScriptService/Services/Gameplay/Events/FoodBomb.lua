--> Services
-----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")

--> Modules
-----------------------------------------
local Signal = require("@Packages/Signal")
local Knit = require("@Packages/Knit")
local Trove = require("@Packages/Trove")

local GeneralInfo = require("@Info/GeneralInfo")

--> Assets
-----------------------------------------
local Assets = ServerStorage:WaitForChild("Assets")
local SoundEffects = ReplicatedStorage:WaitForChild("Models"):WaitForChild("SoundEffects")
local BombModel = Assets:WaitForChild("FoodBomb")
local SpeedBoostModel = Assets:WaitForChild("SpeedBoost")

local ScriptingProperties = workspace:WaitForChild("Game"):WaitForChild("ScriptingProperties")
local EventScriptingItems = ScriptingProperties:WaitForChild("Events")
local FoodBombItems = EventScriptingItems:WaitForChild("FoodBomb")
local ItemSpawnPoints = FoodBombItems:WaitForChild("ItemSpawnPoints")
local PowerupHolder = FoodBombItems:WaitForChild("PowerupHolder")

--> Setup
-----------------------------------------
local FoodBomb = Knit.CreateService({
	Name = "FoodBomb",
	Client = {
		EventSubStatus = Knit.CreateProperty(""),
		EventStatus = Knit.CreateProperty(""),
		WeightGained = Knit.CreateSignal(),
	},
})

--> Variables
-----------------------------------------
FoodBomb.ModeEnded = Signal.new()
FoodBomb.ExplodeTime = 60
FoodBomb.PlayerWithFood = nil
FoodBomb.Trove = Trove.new()
FoodBomb.MaxWeightGained = 250
FoodBomb.MinPlayers = 2 -- 2
FoodBomb.LockWorkoutMachines = true
FoodBomb.YieldClock = true
FoodBomb.Details = {
	Text = "Food Bomb Event!",
	Image = "rbxassetid://70526751887027",
}

local fireColorSequence = {
	ColorSequenceKeypoint.new(0, Color3.new(0, 0.333333, 1)),
	ColorSequenceKeypoint.new(1, Color3.new(0.341176, 0.768627, 1)),
}

--> Utility Functions
-----------------------------------------

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

function getColorFromValue(value, maxValue)
	if value <= 0 then
		return Color3.fromRGB(255, 0, 0)
	end
	if value >= maxValue then
		return Color3.fromRGB(255, 255, 255)
	end

	local ratio = value / maxValue

	if ratio < 0.5 then
		local t = ratio * 2
		return Color3.fromRGB(255, 255 * t, 0)
	else
		local t = (ratio - 0.5) * 2
		return Color3.fromRGB(255, 255, 255 * t)
	end
end

function playBombTick(sound, duration, minInterval, maxInterval)
	local startTime = tick()
	local endTime = startTime + duration
	while tick() < endTime do
		local timeLeft = endTime - tick()
		local interval = math.clamp(timeLeft / duration * maxInterval, minInterval, maxInterval)

		sound:Play()
		task.wait(interval)
	end
	for _ = 1, 5 do
		sound:Play()
		task.wait(minInterval / 4)
	end
end

function isInteger(num)
	return type(num) == "number" and num % 1 == 0
end

function ExplodeFood(Character)
	local Explosion = Instance.new("Explosion")
	Explosion.Position = Character.HumanoidRootPart.Position
	Explosion.BlastRadius = 0
	Explosion.BlastPressure = 0
	Explosion.ExplosionType = Enum.ExplosionType.NoCraters
	Explosion.DestroyJointRadiusPercent = 0

	Explosion.Parent = Character
	SoundEffects.Eliminated:Play()
end

function CreateTrail(Character, Time)
	for _, v in pairs(Character:GetChildren()) do
		if v:IsA("BasePart") then
			local Att1 = Instance.new("Attachment")
			Att1.Parent = v
			Att1.Orientation = Vector3.new(-90, 0, 0)
			Att1.Position = Vector3.new(0, 0.5, 0)
			local Att2 = Instance.new("Attachment")
			Att2.Parent = v
			Att2.Orientation = Vector3.new(-90, 0, 0)
			Att2.Position = Vector3.new(0, -0.5, 0)
			local Trail = Instance.new("Trail")
			Trail.Parent = v
			Trail.Color = ColorSequence.new(fireColorSequence)
			Trail.Attachment0 = Att1
			Trail.Attachment1 = Att2
			Trail.Lifetime = 0.2
			Debris:AddItem(Att1, Time)
			Debris:AddItem(Att2, Time)
			Debris:AddItem(Trail, Time)
		end
	end
end

function SpeedPowerup(Powerup, spot)
	local TouchDebounce = false
	Powerup.Handle.Touched:Connect(function(hit)
		if TouchDebounce then
			return
		end
		TouchDebounce = true
		task.delay(2, function()
			TouchDebounce = false
		end)
		if not hit.Parent:FindFirstChild("Humanoid") then
			return
		end
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)

		local speedBoostTime = 6
		repeat
			task.wait()
		until CheckIfAlive(player)
		Powerup:Destroy()
		spot:RemoveTag("SpotTaken")
		local character = player.Character
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		humanoid.WalkSpeed = 30
		CreateTrail(character, speedBoostTime)
		task.wait(speedBoostTime)
		humanoid.WalkSpeed = 16
	end)
end

--> Main Functions
-----------------------------------------

function FoodBomb:BombCountdown(food)
	for i = self.ExplodeTime, 0, -1 do
		self.Client.EventStatus:Set(`Bomb explodes in {i}`)
		food.Handle.TimeBoard.Count.TextColor3 = getColorFromValue(i, self.ExplodeTime)
		food.Handle.TimeBoard.Count.Text = i
		if isInteger(i / 15) and i < self.ExplodeTime - 10 then
			self:DropPowerups(2, SpeedBoostModel, SpeedPowerup)
		end
		if i == 7 then
			task.spawn(function()
				playBombTick(food.Handle.BombTick, 5, 1, 1)
			end)
		end
		task.wait(1)
	end
	local Owner = self.PlayerWithFood
	local s, e = pcall(function()
		ExplodeFood(food.Parent)
	end)
	if not s then
		warn(e)
	end
	self.Client.EventStatus:Set(`Food Bomb exploded on: {Owner.DisplayName}`)
	task.wait(0.5)
	return Owner
end

function FoodBomb:GetPlayer()
	local plrs = {}
	for _, plr in game.Players:GetPlayers() do
		if plr:HasTag("Eliminated") or not CheckIfAlive(plr) then
			continue
		end
		table.insert(plrs, plr)
	end
	return plrs[math.random(1, #plrs)]
end

function FoodBomb:RedistributeBomb(food)
	food.Parent = workspace
	local plr = self:GetPlayer()
	food.Parent = plr.Character
	self.PlayerWithFood = plr
	self.Client.EventSubStatus:Set(`{plr.DisplayName} has the bomb!`)
	pcall(function()
		self.PlayerWithFood.Character.Humanoid.WalkSpeed = 20
	end)
end

function FoodBomb:ControlBombDeliver(food)
	self:RedistributeBomb(food)
	self.Trove:Connect(game.Players.PlayerRemoving, function(player)
		if player == self.PlayerWithFood then
			self:RedistributeBomb(food)
		end
	end)
end

function FoodBomb:DropBomb(food: Tool)
	local handle = food:FindFirstChild("Handle") :: BasePart

	handle.SmokeLoop:Play()
	FoodBomb:ControlBombDeliver(food)
	local TouchedDebounce = false

	self.Trove:Connect(handle.Touched, function(Hit)
		if not Hit.Parent:FindFirstChild("Humanoid") then
			return
		end
		if TouchedDebounce then
			return
		end
		TouchedDebounce = true
		task.delay(2, function()
			TouchedDebounce = false
		end)
		if food.Parent == workspace then
			food.Parent = Hit.Parent
			return
		end

		local Mag = (Hit.Position - handle.Position).magnitude
		if Mag > 10 then
			TouchedDebounce = false
			return
		end

		food.Parent = workspace
		if handle.Anchored then
			handle.Anchored = false
		end
		food.Parent = Hit.Parent
		local plr = game.Players:GetPlayerFromCharacter(Hit.Parent)
		pcall(function()
			Hit.Parent.Humanoid.WalkSpeed = 20
			FoodBomb.PlayerWithFood.Character.Humanoid.WalkSpeed = 16
		end)
		FoodBomb.PlayerWithFood = plr
		self.Client.EventSubStatus:Set(`{plr.DisplayName} has the food!`)
	end)
	FoodBomb.Trove:Connect(food.Unequipped, function()
		if food.Parent == nil then
			return
		end
		food.Parent = FoodBomb.PlayerWithFood.Character
	end)
end

function FoodBomb:DropPowerups(Count, Powerup, func)
	local function getUntakenSpot()
		local items = ItemSpawnPoints:GetChildren()
		local availableSpots = {}

		for _, spot in ipairs(items) do
			if not spot:HasTag("SpotTaken") then
				table.insert(availableSpots, spot)
			end
		end

		if #availableSpots == 0 then
			return nil
		end

		local spot = availableSpots[math.random(1, #availableSpots)]
		spot:AddTag("SpotTaken")
		return spot
	end

	for _ = 1, Count do
		local spot = getUntakenSpot()
		if not spot then
			break
		end

		local Powerupclone = self.Trove:Add(Powerup:Clone())

		Powerupclone.Parent = PowerupHolder
		Powerupclone:MoveTo(spot.Position)
		task.spawn(func, Powerupclone, spot)
	end
end

function FoodBomb:Start()
	self.EventsService.Client.EnableEventsInterfaces:FireAll(true, "FoodBomb")
	self.ClockService:YieldClock()
	local Food = self.Trove:Add(BombModel:Clone())
	FoodBomb:DropBomb(Food)
	FoodBomb:DropPowerups(2, SpeedBoostModel, SpeedPowerup)
	local LastPlayer = FoodBomb:BombCountdown(Food)
	Food:Destroy()
	task.spawn(function()
		local WeightGained = self.MaxWeightGained * self.ClockService.Days / GeneralInfo.MaxDays
		LastPlayer.leaderstats.Weight.Value += WeightGained
		self.Client.WeightGained:Fire(LastPlayer, WeightGained)
	end)
	task.wait(3)
	-- FoodBomb.ModeEnded:Fire(LastPlayer)
	self:Clean()
end

function FoodBomb:Clean()
	self.EventsService.Client.EnableEventsInterfaces:FireAll(false)
	self.ClockService:ResumeClock()
	for _, v in ItemSpawnPoints:GetChildren() do
		v:RemoveTag("SpotTaken")
	end
	self.Trove:Clean()
end

function FoodBomb:KnitStart()
	self.GeneralService = Knit.GetService("GeneralGameplay")
	self.ClockService = Knit.GetService("ClockService")
	self.EventsService = Knit.GetService("EventsService")

	-- FoodBomb.ModeEnded:Connect(function(PlayerWithFood)

	-- end)
end

return FoodBomb
