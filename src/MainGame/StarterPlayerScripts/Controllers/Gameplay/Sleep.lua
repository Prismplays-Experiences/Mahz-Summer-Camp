--> Services
----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--> Assets
----------------------------------------
ReplicatedStorage:WaitForChild("Assets")
local Models = ReplicatedStorage:WaitForChild("Models")
local SoundEffects = Models:WaitForChild("SoundEffects")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")
local HardNotification = require("@Modules/HardNotification")

--> Variables
----------------------------------------
local Player = game.Players.LocalPlayer
local SleepAnimationID = "rbxassetid://" .. "76420047878908"
local RiseAnimationId = "rbxassetid://" .. "97187272193981"
local Camera = workspace.CurrentCamera

--> Utility Functions
----------------------------------------
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

--> Main Functions
----------------------------------------

local SleepController = Knit.CreateController({
	Name = "SleepService",
})

function SleepController:PlayAnim()
	self.SleepTrack:Play()
	self.SleepTrack.Priority = Enum.AnimationPriority.Action
end

function SleepController:EndAnim()
	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = Player.Character.Humanoid
	self.GeneralController:TransitionToDay()
	self.RiseTrack:Play()
	self.RiseTrack:AdjustSpeed(2)
	self.RiseTrack.Priority = Enum.AnimationPriority.Action2
	self.SleepTrack:Stop()
	task.wait(1)

	HardNotification.Send(Player, "Good Morning", "rbxassetid://84049656723836", SoundEffects.Positive)
end

--> Knit Start
----------------------------------------

function SleepController:KnitStart()
	self.WorkoutsHandler = Knit.GetController("WorkoutsHandler")
	self.GeneralController = Knit.GetController("GeneralControllers")
	local SleepAnimation = Instance.new("Animation")
	local RiseAnimation = Instance.new("Animation")

	SleepAnimation.AnimationId = SleepAnimationID
	RiseAnimation.AnimationId = RiseAnimationId

	local function LoadAnim()
		self.SleepTrack = Player.Character.Humanoid.Animator:LoadAnimation(SleepAnimation)
		self.RiseTrack = Player.Character.Humanoid.Animator:LoadAnimation(RiseAnimation)
	end

	if CheckIfAlive(Player) then
		LoadAnim()
	end
	Player.CharacterAdded:Connect(function()
		LoadAnim()
	end)

	local BedService = Knit.GetService("BedService")

	BedService.SleepAnim:Connect(function(Boolean)
		if Player:HasTag("Eliminated") then
			return
		end
		if Boolean then
			if self.WorkoutsHandler.InWorkout then
				self.WorkoutsHandler:StopWorkout()
			end
			self:PlayAnim()
		else
			self:EndAnim()
		end
	end)
end

return SleepController
