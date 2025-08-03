local PhysicsService = game:GetService("PhysicsService")

local Knit = require("@Packages/Knit")
local Signal = require("@Packages/Signal")

export type RagdollProperties = {
	active: boolean,
	motors: { Motor6D },
	ballSockets: { BallSocketConstraint },
	collisionParts: { Part },
}

export type RagdollService = {
	_ragdollsProperties: { [Player]: RagdollProperties } | {},
	_playersService: {[any]: any},

	Ragdolled: Signal.Signal<Player>,
	Deragdolled: Signal.Signal<Player>,

	Ragdoll: (self: RagdollService, player: Player) -> (),
	Deragdoll: (self: RagdollService, player: Player) -> (),
	IsRagdoll: (self: RagdollService, player: Player) -> (),

	_createCollisionGroups: (self: RagdollService) -> (),
	_setProperties: (self: RagdollService) -> (),
	_createSignals: (self: RagdollService) -> (),
	_connectEvents: (self: RagdollService) -> (),
	_changeRagdollPhysicsState: (self: RagdollService, player: Player, state: boolean) -> (),
	_initConfigureHumanoid: (character: Model) -> (),
	_createMotorsArray: (self: RagdollService, player: Player) -> (),
	_createBallSocketsArray: (self: RagdollService, player: Player) -> (),
	_createCollisionParts: (self: RagdollService, player: Player) -> (),
	_changeMotorsEnabledState: (self: RagdollService, player: Player, state: boolean) -> (),
	_changeBallSocketsEnabledState: (self: RagdollService, player: Player, state: boolean) -> (),
	_changeCollideStateOfParts: (self: RagdollService, player: Player, state: boolean) -> (),
	_configureHumanoid: (player: Player, isRagdoll: boolean) -> (),
	_changeJointsEnabledState: (joints: { Motor6D | BallSocketConstraint }, state: boolean) -> (),
	_getBallSockets: (self: RagdollService, player: Player) -> ({ BallSocketConstraint }),
	_getMotors: (self: RagdollService, player: Player) -> ({ Motor6D }),
	_getCollisionParts: (self: RagdollService, player: Player) -> ({ Part }),
	_setRagdollState: (self: RagdollService, player: Player, state: boolean) -> (),

}

local RagdollService = Knit.CreateService({
	Name = "RagdollService",
	Client = {},
})

function RagdollService.KnitInit(self: RagdollService)
	self:_createCollisionGroups()
	self:_setProperties()
	self:_createSignals()
end

function RagdollService.KnitStart(self: RagdollService)
	self:_connectEvents()
end

function RagdollService.Ragdoll(self: RagdollService, player: Player)
	self:_changeRagdollPhysicsState(player, true)
end

function RagdollService.Deragdoll(self: RagdollService, player: Player)
	self:_changeRagdollPhysicsState(player, false)
end

function RagdollService.IsRagdoll(self: RagdollService, player: Player)
	return self._ragdollsProperties[player].active
end

function RagdollService._createCollisionGroups()
	PhysicsService:RegisterCollisionGroup("Players")
	PhysicsService:RegisterCollisionGroup("WeldedParts")

	PhysicsService:CollisionGroupSetCollidable("Players", "WeldedParts", false)
	PhysicsService:CollisionGroupSetCollidable("Players", "Players", false)
	PhysicsService:CollisionGroupSetCollidable("WeldedParts", "WeldedParts", false)
end

function RagdollService._setProperties(self: RagdollService)
	self._ragdollsProperties = {}
	self._playersService = Knit.GetService("PlayersService")
end

function RagdollService._createSignals(self: RagdollService)
	self.Ragdolled = Signal.new()
	self.Deragdolled = Signal.new()
end

function RagdollService._connectEvents(self: RagdollService)
	task.wait(4)

	self._playersService:AddCharacterFunction(function(character, player)
		self._ragdollsProperties[player] = {}
		self._ragdollsProperties[player].active = false
		self._ragdollsProperties[player].motors = {}
		self._ragdollsProperties[player].ballSockets = {}
		self._ragdollsProperties[player].collisionParts = {}

		self._initConfigureHumanoid(character)
		self:_createMotorsArray(player)
		self:_createBallSocketsArray(player)
		self:_createCollisionParts(player)
	end)
end

function RagdollService._changeRagdollPhysicsState(self: RagdollService, player: Player, state: boolean)
	if self:IsRagdoll(player) == state then
		return
	end

	self:_changeMotorsEnabledState(player, not state)
	self:_changeBallSocketsEnabledState(player, state)
	self:_changeCollideStateOfParts(player, state)

	self._configureHumanoid(player, state)
	self:_setRagdollState(player, state)
end

function RagdollService._initConfigureHumanoid(character: Model)
	local humanoid = character:FindFirstChild("Humanoid")

	humanoid.RequiresNeck = false
	humanoid.BreakJointsOnDeath = false
end

function RagdollService._setRagdollState(self: RagdollService, player: Player, state: boolean)
	if state then
		self.Ragdolled:Fire(player)
	else
		self.Deragdolled:Fire(player)
	end

	self._ragdollsProperties[player].active = state
end

function RagdollService._createMotorsArray(self: RagdollService, player: Player)
	local character = player.Character or player.CharacterAdded:Wait()

	character = workspace:WaitForChild(character.Name)

	for _, motor6D: Motor6D in character:GetDescendants() do
		if not motor6D:IsA("Motor6D") or (motor6D.Parent :: MeshPart).Name == "Head" then
			continue
		end

		table.insert(self:_getMotors(player), motor6D)
	end
end

function RagdollService._createBallSocketsArray(self: RagdollService, player: Player)
	for _, motor6D: Motor6D in self:_getMotors(player) do
		local attachment0 = Instance.new("Attachment")
		attachment0.Name = "RagdollAttachment"
		attachment0.CFrame = motor6D.C0
		attachment0.Parent = motor6D.Part0

		local attachment1 = Instance.new("Attachment")
		attachment1.Name = "RagdollAttachment"
		attachment1.CFrame = motor6D.C1
		attachment1.Parent = motor6D.Part1

		local socket = Instance.new("BallSocketConstraint")
		socket.Name = motor6D.Name
		socket.Attachment0 = attachment0
		socket.Attachment1 = attachment1
		socket.LimitsEnabled = true
		socket.TwistLimitsEnabled = true
		socket.Parent = motor6D.Parent
		socket.Enabled = false

		table.insert(self:_getBallSockets(player), socket)
	end
end

function RagdollService._createCollisionParts(self: RagdollService, player: Player)
	local character = player.Character or player.CharacterAdded:Wait()

	for _, limb in character:GetChildren() do
		if not limb:IsA("MeshPart") and not limb:IsA("Part") or limb.Name == "Head" then
			continue
		end

		local collisionPart = Instance.new("Part")
		collisionPart.Parent = limb
		collisionPart.Size = Vector3.one / 2
		collisionPart.Transparency = 0.5
		collisionPart.Massless = true
		collisionPart.CanCollide = false

		local highlight = Instance.new("Highlight")
		highlight.Parent = collisionPart
		highlight.FillColor = Color3.new(1, 0, 0)
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

		local weld = Instance.new("Weld")
		weld.Parent = collisionPart
		weld.Part0 = limb
		weld.Part1 = collisionPart

		limb.CollisionGroup = "Players"
		collisionPart.CollisionGroup = "WeldedParts"

		table.insert(self:_getCollisionParts(player), collisionPart)
	end
end

function RagdollService._changeMotorsEnabledState(self: RagdollService, player: Player, state: boolean)
	self._changeJointsEnabledState(self:_getMotors(player), state)
end

function RagdollService._changeBallSocketsEnabledState(self: RagdollService, player: Player, state: boolean)
	self._changeJointsEnabledState(self:_getBallSockets(player), state)
end

function RagdollService._changeCollideStateOfParts(self: RagdollService, player: Player, state: boolean)
	local collisionParts = self:_getCollisionParts(player)

	for _, part: Part in pairs(collisionParts) do
		part.CanCollide = state
	end
end

function RagdollService._configureHumanoid(player: Player, isRagdoll: boolean)
	local character = player.Character or player.CharacterAdded:Wait()

	if not character then
		return
	end

	local humanoid: Humanoid = character.Humanoid

	humanoid.AutoRotate = not isRagdoll
	humanoid.PlatformStand = isRagdoll

	if isRagdoll then
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	else
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

function RagdollService._changeJointsEnabledState(joints: { { Enabled: boolean } & Instance }, state: boolean)
	for _, joint in joints do
		joint.Enabled = state
	end
end

function RagdollService._getBallSockets(self: RagdollService, player: Player)
	return self._ragdollsProperties[player].ballSockets
end

function RagdollService._getMotors(self: RagdollService, player: Player)
	return self._ragdollsProperties[player].motors
end

function RagdollService._getCollisionParts(self: RagdollService, player: Player)
	return self._ragdollsProperties[player].collisionParts
end

return RagdollService
