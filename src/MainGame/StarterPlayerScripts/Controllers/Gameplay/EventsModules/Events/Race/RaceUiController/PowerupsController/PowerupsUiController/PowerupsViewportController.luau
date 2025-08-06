local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local RaceInfo = require("@Info/Events/RaceInfo")
local CFrameUtils = require("@Modules/Utils/CFrameUtils")
local Knit = require("@Packages/Knit")
local types = require("../../../types")

local player = Players.LocalPlayer

local POWERUP_BUTTON = RaceInfo.ui.powerupButton(player)
local VIEWPORT_FRAME = POWERUP_BUTTON:FindFirstChild("ViewportFrame") :: ViewportFrame

local CAMERA_POSITION = RaceInfo.ui.powerupButtonCameraPosition
local CAMERA_FOV = RaceInfo.ui.powerupButtonCameraFov
local ROTATION_SPEED = RaceInfo.ui.powerupInstanceRotationSpeed
local POWERUPS_TEMPLATES = {
	bomb = RaceInfo.instances.powerups.bombTemplate,
	iceBlock = RaceInfo.instances.powerups.smallIceBlockTemplate,
}

type PowerupsViewportController = types.PowerupsViewportController

local PowerupsViewportController = Knit.CreateController({
	Name = "PowerupsViewportController",
})

function PowerupsViewportController.KnitInit(self: PowerupsViewportController)
	self:_setProperties()
	self:_connectEvents()
end

function PowerupsViewportController.AddViewportInstance(self: PowerupsViewportController, powerupName: string)
	local powerupInstance = self._getPowerupInstance(powerupName)

	if not powerupInstance then
		return
	end

	self:_setViewportInstance(powerupInstance)
	self:_insertViewportInstance(powerupInstance)
end

function PowerupsViewportController.CleanViewportInstance(self: PowerupsViewportController)
	local viewportInstance = self:GetViewportInstance()

	viewportInstance:Destroy()
end

function PowerupsViewportController.GetViewportInstance(self: PowerupsViewportController): Model | MeshPart
	local viewportInstance = self._viewportInstance

	return viewportInstance
end

function PowerupsViewportController._setProperties(self: PowerupsViewportController)
	self._viewportFrame = VIEWPORT_FRAME
end

function PowerupsViewportController._connectEvents(self: PowerupsViewportController)
	RunService.RenderStepped:Connect(function()
		self:_rotateViewportInstance(ROTATION_SPEED)
	end)
end

function PowerupsViewportController._rotateViewportInstance(self: PowerupsViewportController, angle: number)
	local powerupInstance = self:GetViewportInstance()

	if not powerupInstance then
		return
	end

	local oldCframe = CFrameUtils.GetCframe(powerupInstance)
	local newCframe = oldCframe * CFrame.Angles(0, math.rad(angle), 0)

	CFrameUtils.SetCframe(powerupInstance, newCframe)
end

function PowerupsViewportController._insertViewportInstance(self: PowerupsViewportController, instance)
	local viewportFrame = self:_getViewportFrame()
	local camera = viewportFrame.CurrentCamera

	if not camera then
		camera = Instance.new("Camera")
		viewportFrame.CurrentCamera = camera
	end

	instance.Parent = viewportFrame
	CFrameUtils.SetPosition(instance, Vector3.zero)

	camera.CFrame = CFrame.new(CAMERA_POSITION, Vector3.zero)
	camera.FieldOfView = CAMERA_FOV
end

function PowerupsViewportController._setViewportInstance(self: PowerupsViewportController, instance: Model | MeshPart)
	self._viewportInstance = instance
end

function PowerupsViewportController._getPowerupInstance(powerupName: string): Model | MeshPart
	return POWERUPS_TEMPLATES[powerupName]:Clone()
end

function PowerupsViewportController._getViewportFrame(self: PowerupsViewportController): ViewportFrame
	return self._viewportFrame
end

return PowerupsViewportController
