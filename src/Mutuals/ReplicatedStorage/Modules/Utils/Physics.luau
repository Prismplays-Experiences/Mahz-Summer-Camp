local Debris = game:GetService("Debris")

local Knit = require("@Packages/Knit")
export type Physics = {
	ApplyImpulseToPlayer: (self: Physics, impulse: Vector3, player: Player) -> (),
	ApplyImpulseRelativeToLookVector: (impulse: Vector3, part: Part) -> (),
	ApplyImpulse: (impulse: Vector3, player: Player, lookVector: Vector3?) -> (),
}

local Physics = {}

function Physics.ApplyImpulseToPlayer(self: Physics, impulse: Vector3, player: Player, notAVelocity: boolean?)
	local character = player.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	if notAVelocity then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part:SetNetworkOwner(nil)
			end
		end

		self.ApplyImpulseRelativeToLookVector(impulse, humanoidRootPart)

		task.delay(2, function()
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part:SetNetworkOwner(player)
				end
			end
		end)
	else
		self.ApplyImpulse(impulse, player)
	end
end

function Physics.ApplyImpulseRelativeToLookVector(impulse: Vector3, part: Part)
	local lookVector = part.CFrame.LookVector
	local rightVector = part.CFrame.RightVector

	local zComponent = impulse.Z * lookVector
	local yComponent = impulse.Y * Vector3.yAxis
	local xComponent = impulse.X * rightVector

	local resultVector = xComponent + yComponent + zComponent

	part:ApplyImpulse(resultVector)
end

function Physics.ApplyImpulse(impulse: Vector3, player: Player, lookVector: Vector3?)
	local playerCharacter = player.Character
	local humanoidRootPart = playerCharacter.HumanoidRootPart
	local humanoid = playerCharacter:FindFirstChildOfClass("Humanoid")
	local ragdollService = Knit.GetService("RagdollService")

	lookVector = lookVector or humanoidRootPart.CFrame.LookVector

	local playerMass = Physics.GetMass(playerCharacter)
	local speed = impulse.Z
	local maxForce = 80000

	local knockback = Instance.new("BodyVelocity")

	local massMultiplier = playerMass / 600

	local knockbackVelocity = lookVector * speed + impulse.Y * Vector3.yAxis
	knockbackVelocity *= massMultiplier

	humanoid.PlatformStand = true
	humanoid.WalkToPart = nil
	humanoid.WalkToPoint = humanoidRootPart.Position

	knockback.Parent = humanoidRootPart
	knockback.MaxForce = Vector3.new(maxForce, maxForce, maxForce)
	knockback.Velocity = knockbackVelocity

	Debris:AddItem(knockback, 0.22)

	task.delay(0.3, function()
		if ragdollService:IsRagdoll(player) then
			return
		end

		humanoid.PlatformStand = false
	end)
end

function Physics.GetMass(instance: Instance)
	local mass = 0

	for _, part in instance:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		mass += part.AssemblyMass
	end

	return mass
end

return Physics
