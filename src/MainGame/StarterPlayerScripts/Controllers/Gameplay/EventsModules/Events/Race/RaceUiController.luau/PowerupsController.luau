local Players = game:GetService("Players")

local RaceInfo = require("@Info/Events/RaceInfo")
local Knit = require("@Packages/Knit")

local types = require("../types")

type PowerupsController = types.PowerupsController

local CAMERA_POSITION = RaceInfo.ui.powerupButtonCameraPosition
local POWERUPS_TEMPLATES = {
	bomb = RaceInfo.instances.powerups.bombTemplate,
	iceTrap = RaceInfo.instances.powerups.smallIceBlockTemplate,
}

local player = Players.LocalPlayer

local PowerupsController = Knit.CreateController { Name = "PowerupsController" }

function PowerupsController.KnitInit(self: PowerupsController)
	self:_setProperties()
	self:_connectEvents()
end

function PowerupsController._setProperties(self: PowerupsController)
	self._powerupsService = Knit.GetService("PowerupsService")
	self._powerupBox = RaceInfo.ui.powerupButton(player)
end

function PowerupsController._connectEvents(self: PowerupsController)
	local powerupBox = self:GetPowerupBox()
	local service = self:GetPowerupsService()

	powerupBox.MouseButton1Click:Connect(function()
		self:Use()
	end)

	service.PowerupReceived:Connect(function(powerupName: string)
		self:SetPowerup(powerupName)
		self:UpdatePowerupBox()
	end)
end

function PowerupsController.SetVisible(self: PowerupsController, visible: boolean)
	local powerupBox = self:GetPowerupBox()

	powerupBox.Visible = visible
end

function PowerupsController.Use(self: PowerupsController): boolean
	local service = self:GetPowerupsService()

	return service:Use(player)
end

function PowerupsController.UpdatePowerupBox(self: PowerupsController)
	local instance = self:_getPowerupInstance()

	if not instance then
		return
	end

	self:_cleanViewport()
	self:_addToViewport(instance)
end

function PowerupsController.SetPowerup(self: PowerupsController, powerupName: string)
	self._powerup = powerupName
end

function PowerupsController.GetPowerup(self: PowerupsController): string?
	return self._powerup
end

function PowerupsController.GetPowerupBox(self: PowerupsController): ImageButton
	return self._powerupBox
end

function PowerupsController.GetPowerupsService(self: PowerupsController): {Use: () -> boolean}
	return self._powerupsService
end

function PowerupsController._getPowerupInstance(self: PowerupsController): Part | Model?
	local powerupName = self:GetPowerup()

	return POWERUPS_TEMPLATES[powerupName]
end

function PowerupsController._addToViewport(self: PowerupsController, instance)
	local powerupBox = self:GetPowerupBox()
	local viewport = powerupBox.ViewportFrame
	local camera = viewport.CurrentCamera

	if not camera then
		camera = Instance.new("Camera")
		viewport.CurrentCamera = camera
	end

	instance.Parent = viewport
	self._setPosition(instance, Vector3.zero)

	camera.CFrame = CFrame.new(CAMERA_POSITION, Vector3.zero)
end

function PowerupsController._cleanViewport(self: PowerupsController)
	local powerupBox = self:GetPowerupBox()
	local viewport = powerupBox.ViewportFrame

	for _, child in ipairs(viewport:GetChildren()) do
		if not child:IsA("Camera") then
			child:Destroy()
		end
	end
end

function PowerupsController._setPosition(instance: Instance, position: Vector3)
	if (instance :: Model).PivotTo then
		(instance :: Model):PivotTo(CFrame.new(position))
	else
		(instance :: Part).Position = position
	end
end

return PowerupsController
