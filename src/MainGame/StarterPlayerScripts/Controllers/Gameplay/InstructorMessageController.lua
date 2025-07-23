--> Services
----------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")

--> Assets
----------------------------------------
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main")

--> Variables
----------------------------------------

local BaseAnim = Instance.new("Animation")
BaseAnim.AnimationId = "rbxassetid://127679387441945"
local KeyPhrases = {
	Wave = { Text = { "Welcome", "Bye" }, AnimId = "rbxassetid://507770239", AnimSpeed = 0.7 },
	Go = {
		Text = { "GO!", "Now!", "GOO!!", "Goodluck", "See", "careful" },
		AnimId = "rbxassetid://507770453",
		AnimSpeed = 0.6,
	},
	-- Clap = {Text = {''}, AnimId = 'rbxassetid://3312847365', AnimSpeed = 0.7},
}

--> Knit Setup
----------------------------------------
local InstructorMessageController = Knit.CreateController({
	Name = "InstructorMessageController",
})

--> Utility Functions
----------------------------------------

function ZoomCameraFOV(sharpIn: number, holdTime: number, sharpOut: number, inFOV: number, outFOV: number)
	local originalFOV = Camera.FieldOfView

	-- Zoom in
	local tweenIn =
		TweenService:Create(Camera, TweenInfo.new(sharpIn, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			FieldOfView = inFOV,
		})

	-- Zoom out
	local tweenOut =
		TweenService:Create(Camera, TweenInfo.new(sharpOut, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			FieldOfView = outFOV or originalFOV,
		})

	tweenIn:Play()
	tweenIn.Completed:Wait()

	-- Optional hold
	task.wait(holdTime)

	tweenOut:Play()
	tweenOut.Completed:Wait()
end

-- Custom tracking function
function StartTrackingCam(targetCharacter, targetPosition, maxArcDegrees, radius, height)
	local humanoidRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
	if not humanoidRoot then
		return
	end

	local startPosition = humanoidRoot.Position
	local totalDistance = (targetPosition - startPosition).Magnitude
	local connection

	connection = RunService.RenderStepped:Connect(function()
		local currentPos = humanoidRoot.Position
		local movedDistance = (currentPos - startPosition).Magnitude
		local progress = math.clamp(movedDistance / totalDistance, 0, 1)

		-- Angle moves from 0 to maxArcDegrees
		local angle = math.rad(progress * maxArcDegrees)
		local offset = Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius)

		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = CFrame.new(currentPos + offset, currentPos)

		-- Optional: disconnect when they reach the target
		if progress >= 1 then
			connection:Disconnect()
			connection = nil
		end
	end)
	repeat
		task.wait(0.1)
	until connection == nil
	-- Camera.CFrame = CFrame.new(targetPosition + Vector3.new(0, height, radius), targetPosition)
end

function TweenCameraToSubject(subjectPart: BasePart, duration: number, distance: number, height: number)
	local startCFrame = Camera.CFrame

	local subjectPos = subjectPart.Position
	local direction = subjectPart.CFrame.LookVector.Unit
	local endPosition = subjectPos + direction * distance + Vector3.new(0, height, 0)

	local endCFrame = CFrame.new(endPosition, subjectPos)

	local t = 0
	Camera.CameraType = Enum.CameraType.Scriptable

	local connection
	connection = RunService.RenderStepped:Connect(function(dt)
		t += dt / duration
		local alpha = math.clamp(t, 0, 1)

		Camera.CFrame = startCFrame:Lerp(endCFrame, alpha)

		if alpha >= 1 then
			connection:Disconnect()
			connection = nil
		end
	end)
	repeat
		task.wait(0.1)
	until connection == nil
	Camera.CFrame = endCFrame
end

function TypeText(textLabel, desiredtext, speed)
	local msgs = desiredtext
	speed /= #msgs
	for j = 1, #msgs do
		textLabel.Text = string.sub(msgs, 1, j)
		task.wait(speed)
	end
end

function PlayMessage(Instructor, Message)
	local Humanoid = Instructor:FindFirstChildOfClass("Humanoid")
	local CoachBillboard = Instructor:WaitForChild("CoachName")
	local MessageBillboard = Instructor:WaitForChild("Message")
	local TextHolder = MessageBillboard:WaitForChild("TextHolder")
	local TextLabel = TextHolder:WaitForChild("TextLabel")
	TextHolder.Position = UDim2.fromScale(0, 1)
	local TextSpeed = 1.5

	CoachBillboard.Enabled = false
	MessageBillboard.Enabled = true
	TweenService:Create(
		TextHolder,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = UDim2.fromScale(0, 0), ImageTransparency = 0 }
	):Play()
	local CurrentAnim = nil

	local BaseTrack = Humanoid:LoadAnimation(BaseAnim)
	BaseTrack.Priority = Enum.AnimationPriority.Action
	BaseTrack:Play()
	local Sound = Instance.new("Sound")
	Sound.Parent = TextLabel
	Sound.Name = "TextSound"
	Sound.SoundId = "rbxassetid://18910955184"
	Sound.PlaybackSpeed = 1
	Sound.Volume = 1.5
	Sound.Looped = true

	for _, MessageText in ipairs(Message) do
		for _, PhraseTable in KeyPhrases do
			for _, Phrase in PhraseTable.Text do
				if string.find(MessageText, Phrase) then
					local startIndex = string.find(MessageText, Phrase)
					local totalLength = #MessageText
					local charactersBefore = startIndex - 1
					local waitTime = (charactersBefore / totalLength) * 1.5

					task.wait(waitTime)
					if CurrentAnim then
						CurrentAnim:Stop()
					end
					local Animation = Instance.new("Animation")
					Animation.AnimationId = PhraseTable.AnimId

					local Track = Humanoid:LoadAnimation(Animation)
					Track.Priority = Enum.AnimationPriority.Action2
					Track:Play()
					if PhraseTable.AnimSpeed then
						Track:AdjustSpeed(PhraseTable.AnimSpeed)
					end
					Track.Looped = false
					break
				end
			end
		end
		if #MessageText < 4 then
			TextLabel.Text = MessageText
		else
			Sound:Play()
			TypeText(TextLabel, MessageText, 1.5)
			Sound:Stop()
		end
		task.wait(TextSpeed)
	end
	Sound:Destroy()
	BaseTrack:Stop()
	if CurrentAnim then
		CurrentAnim:Stop()
	end
end

--> Main Functions
----------------------------------------
function InstructorMessageController:KnitStart()
	local InstructorService = Knit.GetService("InstructorMessage")
	self.MusicController = Knit.GetController("MusicController")
	self.GeneralController = Knit.GetController("GeneralControllers")

	InstructorService.CameraControl:Connect(function(status, character, target, randomPoint, Message)
		if status then
			pcall(function()
				self.GeneralController.PlayerModule:Disable()
			end)

			self.MusicController:PlayNewSong("StageEvent")
			Main.Enabled = false
			local angle = randomPoint.Name == "2" and 45 or -45
			StartTrackingCam(character, target.Position, angle, 15, 12)
			task.wait(2)
			TweenCameraToSubject(character.Head, 1, 8, -0.5)
			task.wait(1)
			PlayMessage(character, Message)
			task.wait(2)
			local FOV = Camera.FieldOfView
			ZoomCameraFOV(0.3, 0.05, 0.3, FOV - 30, FOV + 25)
			Camera.CameraType = Enum.CameraType.Custom
			local t = TweenService:Create(Camera, TweenInfo.new(0.5), { FieldOfView = FOV })
			t:Play()
			t.Completed:Wait()
			Camera.FieldOfView = FOV
			Camera.CameraType = Enum.CameraType.Custom
			character:Destroy()
			self.MusicController:PlayNewSong("Normal")
			pcall(function()
				self.GeneralController.PlayerModule:Enable()
			end)

			Main.Enabled = true
		else
			pcall(function()
				self.GeneralController.PlayerModule:Enable()
			end)
			Main.Enabled = true
			Camera.CameraType = Enum.CameraType.Custom
		end
	end)
end

return InstructorMessageController
