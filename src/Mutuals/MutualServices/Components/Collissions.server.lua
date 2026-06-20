local PhysicsService = game:GetService("PhysicsService")

local BorderCollissionGroup = "BorderCollision"
local PlayerCollissionGroup = "PlayerCollission"
local NPCCollision = "NPCCollision"

PhysicsService:RegisterCollisionGroup(BorderCollissionGroup)
PhysicsService:RegisterCollisionGroup(PlayerCollissionGroup)
PhysicsService:RegisterCollisionGroup(NPCCollision)

PhysicsService:RegisterCollisionGroup('Doors')
PhysicsService:RegisterCollisionGroup('DoorsWalkThrough')
PhysicsService:CollisionGroupSetCollidable("Doors", "DoorsWalkThrough", false)


PhysicsService:CollisionGroupSetCollidable(PlayerCollissionGroup, PlayerCollissionGroup, false)
PhysicsService:CollisionGroupSetCollidable(PlayerCollissionGroup, NPCCollision, false)
PhysicsService:CollisionGroupSetCollidable(NPCCollision, NPCCollision, false)

PhysicsService:CollisionGroupSetCollidable(BorderCollissionGroup, PlayerCollissionGroup, true)
PhysicsService:CollisionGroupSetCollidable(BorderCollissionGroup, NPCCollision, false)

function TurnOfCollisions(Character)
	for _, BodyPart in pairs(Character:GetDescendants()) do
		if BodyPart:IsA("Part") or BodyPart:IsA("MeshPart") then
			--BodyPart:SetNetworkOwner(player)
			BodyPart.CollisionGroup = PlayerCollissionGroup
		end
	end
end

function PlayerAdded(player)
	player.CharacterAdded:Connect(function(char)
		TurnOfCollisions(char)
	end)
end

for _, v in pairs(game.Players:GetPlayers()) do
	if game:GetService("RunService"):IsStudio() then
		PlayerAdded(v)
	end
end

game:GetService("Players").PlayerAdded:Connect(PlayerAdded)
