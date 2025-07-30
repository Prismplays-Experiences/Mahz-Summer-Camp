local Mathematics = {}

local MAX_ANGLE = 2 * math.pi

-- In polar coordinates
function Mathematics.CalculateAngleBetweenPlayerAndPart(player: Player, part: BasePart, additionalAngle: number?, areDegrees: boolean?): number
	local playerPosition = Mathematics.GetPlayerPosition(player)
	local partPosition = part.Position
	local partOrientation = part.Orientation.Y * math.pi / 180

	additionalAngle = (additionalAngle or 0) + partOrientation

	return Mathematics.CalculateAngleBetweenVectors(partPosition, playerPosition, additionalAngle, areDegrees)
end

-- In polar coordinates
function Mathematics.CalculateAngleBetweenVectors(centerPosition: Vector3, pointPosition: Vector3, additionalAngle: number?, areDegrees: boolean?): number
	local differenceVector = Mathematics.GetDifferenceVector2(centerPosition, pointPosition)
	local angle = Mathematics.CalculateAngleOfVector2(differenceVector, additionalAngle, areDegrees)

	return angle
end

-- In polar coordinates
function Mathematics.CalculateAngleOfVector2(diffVector: Vector2, additionalAngle: number?, areDegrees: boolean?): number
	local multiplier = if areDegrees == true then 180 / math.pi else 1
	additionalAngle = additionalAngle or 0

	local angle = math.atan2(diffVector.Y, diffVector.X)
	angle *= multiplier
	angle += additionalAngle * multiplier

	if angle < 0 then
		angle += MAX_ANGLE * multiplier
	end

	return angle
end

function Mathematics.GetDifferenceVector2(centerPosition3: Vector3, pointPosition3: Vector3): Vector2
	local centerPosition2 = Mathematics.Vector3ToVector2(centerPosition3)
	local pointPosition2 = Mathematics.Vector3ToVector2(pointPosition3)

	local differenceVector2 = centerPosition2 - pointPosition2

	return differenceVector2
end

function Mathematics.Vector3ToVector2(vector: Vector3): Vector2
	return Vector2.new(vector.X, vector.Z)
end

function Mathematics.GetPlayerPosition(player: Player): Vector3
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	return humanoidRootPart.Position
end

return Mathematics