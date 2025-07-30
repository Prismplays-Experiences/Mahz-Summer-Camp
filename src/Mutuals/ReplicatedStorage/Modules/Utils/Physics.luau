local Physics = {}

function Physics.ApplyImpulseRelativeToLookVector(impulse: Vector3, part: Part)
	local lookVector = part.CFrame.LookVector
	local rightVector = part.CFrame.RightVector

	local zComponent = impulse.Z * lookVector
	local yComponent = impulse.Y * Vector3.yAxis
	local xComponent = impulse.X * rightVector

	local resultVector = xComponent + yComponent + zComponent

	part:ApplyImpulse(resultVector)
end

return Physics