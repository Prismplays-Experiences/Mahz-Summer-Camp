local RunService = game:GetService("RunService")
local Trove = require("@Packages/Trove")

local DEFAULT_CAMERA_FOV = 5
local ROTATION_SPEED = 45

function RenderModelInViewport(viewportFrame: ViewportFrame, model: Model, fov: number?, rotationSpeed: number?)
	if not viewportFrame or not model then
		return
	end

	fov = fov or DEFAULT_CAMERA_FOV
	rotationSpeed = rotationSpeed or ROTATION_SPEED

	viewportFrame:ClearAllChildren()

	local camera = Instance.new("Camera")
	camera.FieldOfView = fov
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera

	if not model:IsA("Model") then
		local Model = Instance.new("Model")
		model.Parent = Model
		model = Model
	end

	local container = Instance.new("Model")
	container.Name = "ContainerModel"
	container.Parent = viewportFrame

	local modelClone = model:Clone()
	modelClone.Parent = container
	modelClone:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), 0, 0))

	if not modelClone.PrimaryPart then
		local primary = modelClone:FindFirstChildWhichIsA("BasePart")
		if primary then
			modelClone.PrimaryPart = primary
		end
	end

	if not modelClone.PrimaryPart then
		warn("No primary part found for model:", modelClone.Name)
		return
	end

	local cf, size = modelClone:GetBoundingBox()
	local maxDim = math.max(size.X, size.Y, size.Z)
	local dist = maxDim / math.tan(math.rad(camera.FieldOfView)) * 0.85
	local lookTarget = cf.Position
	local camPos = lookTarget - Vector3.new(0, 0, dist)
	camera.CFrame = CFrame.lookAt(camPos, lookTarget)

	local trove = Trove.new()
	trove:AttachToInstance(viewportFrame)

	local offset = CFrame.new(0, 0, 0)
	container:PivotTo(offset)

	local angle = 0
	trove:Connect(RunService.RenderStepped, function(dt)
		angle += dt * math.rad(rotationSpeed :: number) -- 45 degrees/sec
		container:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, angle, 0))
	end)
	return trove
end

return RenderModelInViewport
