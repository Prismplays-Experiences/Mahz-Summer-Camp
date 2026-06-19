local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local RaceInfo = require("@Info/Events/RaceInfo")
local Knit = require("@Packages/Knit")
local Physics = require("@Modules/Utils/Physics")
local types = require("./types")
local Assets = require("@Assets")

local BOMB_SOUND = Assets.sounds.Events.Race.Bobm
local RAGDOLL_DURATION = RaceInfo.powerups.bomb.ragdollDuration
local IMPULSE = RaceInfo.powerups.bomb.impulse
local BOMB_TEMPLATE = RaceInfo.instances.powerups.bombTemplate
local DROP_TWEEN_INFO = RaceInfo.powerups.bomb.dropTweenInfo
local DROP_START_HEIGHT = RaceInfo.powerups.bomb.dropStartHeight

type bombInstance = MeshPart & {
	["Attachment0"]: Attachment,
	["Attachment1"]: Attachment,
	["Trail"]: Trail,
}

type Powerup = types.Powerup & {
	_instance: bombInstance,

	_init: () -> (),

	_dropOnAPlayer: (self: Powerup, player: Player) -> (),
	_explode: (self: Powerup, player: Player) -> (),
	_ragdollPlayer: (player: Player) -> (),
	_flingPlayer: (player: Player) -> (),
	_getInstance: (self: Powerup) -> bombInstance,
	_playSound: () -> (),
}

local Bomb = {}
Bomb.__index = Bomb

function Bomb.Activate(_, targetPlayer: Player)
	if not targetPlayer then
		warn("No target player provided for Bomb activation.")
		return false
	end

	local self = Bomb.new()

	self:_dropOnAPlayer(targetPlayer)
	self:_explode(targetPlayer)
	self._playSound()
	self._ragdollPlayer(targetPlayer)
	self._flingPlayer(targetPlayer)

	return true
end

function Bomb.new()
	local self = setmetatable({}, Bomb)

	self._instance = BOMB_TEMPLATE:Clone()

	return self
end

function Bomb._dropOnAPlayer(self: Powerup, player: Player)
	local playerCharacter = player.Character
	if not playerCharacter then
		return
	end

	local humanoidRootPart = playerCharacter:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	local instance = self:_getInstance()
	instance.Anchored = true
	instance.Parent = workspace

	local numberValue = Instance.new("NumberValue")
	numberValue.Name = "Bomb"
	numberValue.Value = 1
	numberValue.Parent = ReplicatedStorage

	local dropTween = TweenService:Create(numberValue, DROP_TWEEN_INFO, { Value = 0 })
	dropTween:Play()

	numberValue.Changed:Connect(function()
		local alpha = numberValue.Value

		instance.CFrame = humanoidRootPart.CFrame
			* CFrame.new(0, DROP_START_HEIGHT * alpha, 0)
			* CFrame.Angles(math.rad(90), 0, 0)
	end)

	dropTween.Completed:Connect(function()
		numberValue:Destroy()
	end)

	dropTween.Completed:Wait()
end

function Bomb._explode(self: Powerup)
	local instance = self:_getInstance()

	local explosion = Instance.new("Explosion")
	explosion.Parent = workspace
	explosion.Position = instance.Position
	explosion.BlastRadius = 0
	explosion.BlastPressure = 0
	explosion.Parent = workspace
	explosion.ExplosionType = Enum.ExplosionType.NoCraters
	explosion.DestroyJointRadiusPercent = 0

	instance:Destroy()

	Debris:AddItem(explosion, 4)
end

function Bomb._ragdollPlayer(player: Player)
	local ragdollService = Knit.GetService("RagdollService")

	ragdollService:Ragdoll(player)

	task.spawn(function()
		task.wait(RAGDOLL_DURATION)
		ragdollService:Deragdoll(player)
	end)
end

function Bomb._flingPlayer(player: Player)
	local impulse = IMPULSE(player.Character)

	Physics:ApplyImpulseToPlayer(impulse, player, true)
end

function Bomb._getInstance(self: Powerup): bombInstance
	return self._instance
end

function Bomb._playSound()
	local soundPlayerService = Knit.GetService("SoundPlayerService")
	soundPlayerService:PlaySoundById(BOMB_SOUND)
end

return Bomb
