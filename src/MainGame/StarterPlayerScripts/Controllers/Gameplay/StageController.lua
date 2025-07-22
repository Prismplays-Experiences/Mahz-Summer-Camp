--> Services
----------------------------------------
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local Workspace = game:GetService('Workspace')


--> Assets
----------------------------------------
local Assets = ReplicatedStorage:WaitForChild('Assets')
local Models = ReplicatedStorage:WaitForChild('Models')
local SoundEffects = Models:WaitForChild('SoundEffects')
local ScriptingProperties = Workspace:WaitForChild('Game'):WaitForChild('ScriptingProperties')
local StagePropsHolder = ScriptingProperties:WaitForChild('StagePropsHolder')
local CenterCam = StagePropsHolder:WaitForChild('CenterCam')
local CenterCam2 = StagePropsHolder:WaitForChild('CenterCam2')
local StagePropsHolder = ScriptingProperties:WaitForChild('StagePropsHolder')
local StageEffect = StagePropsHolder:WaitForChild('StageEffect')

--> Modules
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild('Packages')
local Knit = require(Packages:WaitForChild('Knit'))
local Trove = require(Packages:WaitForChild('Trove'))
local Modules = ReplicatedStorage:WaitForChild('Modules')

local Modules = ReplicatedStorage:WaitForChild('Modules')
local HardNotification = require(Modules.HardNotification)


--> Variables
----------------------------------------
local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local WeightTrove = Trove.new()
local DefaultFOV  =Camera.FieldOfView
local Main = Player.PlayerGui:WaitForChild('Main')


--> Knit Setup
----------------------------------------

--> Utility Functions
----------------------------------------
function CheckIfAlive(Plr)
	if not Plr.Character then return false end
	local char = Plr.Character
	if char then

		if char.Humanoid.Health <= 0 then
			return false
		end

	end
	return true
end

function TweenNumberOnLabel(label: TextLabel, targetValue: number, duration: number, suffix: string?,halt)
	suffix = suffix or ""

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = tonumber(label.Text:match("%d+")) or 0

	local tween = TweenService:Create(
		numberValue,
		TweenInfo.new(duration or 1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
		{Value = targetValue}
	)

	local connection
	connection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		label.Text = string.format("%d%s", math.floor(numberValue.Value), suffix)
	end)

	tween:Play()

	tween.Completed:Once(function()
		label.Text = string.format("%d%s", targetValue, suffix)
		if connection then connection:Disconnect() end
        connection = nil
		numberValue:Destroy()
	end)
    if halt then
        repeat task.wait(0.1) until not connection
    end
end

function StartTrackingCam(targetCharacter, targetPosition, maxArcDegrees, radius, height)
    local humanoidRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not humanoidRoot then return end

    local startPosition = humanoidRoot.Position
    local totalDistance = (targetPosition - startPosition).Magnitude
    local connection

    connection = RunService.RenderStepped:Connect(function(dt)
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
    repeat task.wait(0.1) until connection == nil
end



local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

function TweenCameraToSubject(subjectPart: BasePart, duration: number, distance: number, height: number)
	local startCFrame = Camera.CFrame
	Camera.CameraType = Enum.CameraType.Scriptable

	local subjectPos = subjectPart.Position
	local lookVector = subjectPart.CFrame.LookVector.Unit

	-- Move to a position behind and above the subject
	local endPosition = subjectPos - (lookVector * distance) + Vector3.new(0, height, 0)

	-- Use subject's rotation to make camera face the same direction
	local subjectRotation = subjectPart.CFrame - subjectPart.Position
	local endCFrame = CFrame.new(endPosition) * subjectRotation

	-- Tween camera manually
	local elapsed = 0
	local connection
	connection = RunService.RenderStepped:Connect(function(dt)
		elapsed += dt
		local alpha = math.clamp(elapsed / duration, 0, 1)
		Camera.CFrame = startCFrame:Lerp(endCFrame, alpha)

		if alpha >= 1 then
			connection:Disconnect()
		end
	end)

	repeat task.wait() until not connection
    Camera.CFrame = endCFrame
end


local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local cam = workspace.CurrentCamera


local function GetCurvePosition(angle, y, mag)
	mag -= 5
	local x = math.sin(math.rad(angle)) * mag
	local z = math.cos(math.rad(angle)) * mag
	return Vector3.new(x, y, z)
end

function CircularCameraMotion(Part, angleOffset, dist, duration)
    local dir = Part.Orientation
	local dist = dist or 40
	local newTargetPos = Part.Position + (Part.CFrame.LookVector.Unit * dist)
	local lookat = Part.Position + (Part.CFrame.LookVector.Unit * dist)
	local mag = (Part.Position-newTargetPos).Magnitude
	newTargetPos = Vector3.new(newTargetPos.X,dir.Y,newTargetPos.Z)
	local StartCF = CFrame.new(GetCurvePosition(60+angleOffset,Part.Position.Y,mag)+newTargetPos-Vector3.new(0,newTargetPos.Y,0),lookat)
	local EndCF =CFrame.new(GetCurvePosition(120+angleOffset,Part.Position.Y,mag)+newTargetPos-Vector3.new(0,newTargetPos.Y,0),lookat)
	local startcftween = TweenService:Create(cam, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = StartCF})
    startcftween:Play()
    startcftween.Completed:Wait(10)
    local startTime = tick()

	local connection
    local completed = false
	connection = RunService.RenderStepped:Connect(function()
		local alpha = math.clamp((tick() - startTime) / duration, 0, 1)
		cam.CFrame = StartCF:Lerp(EndCF, alpha)

		if alpha >= 1 then
			connection:Disconnect()
			completed = true
		end
	end)

	repeat task.wait() until completed

	cam.CameraType = Enum.CameraType.Custom
end

function DefaultCircularCameraMotion()
     CircularCameraMotion(CenterCam2, 180, 0, 6)
end

--> Main Functions
----------------------------------------

local StageController = Knit.CreateController {
	Name = 'StageController'
}

function StageController:KnitStart()
    local StageService = Knit.GetService('StageService')
    self.MusicController = Knit.GetController('MusicController')
    StageService.PlayerCameraTrack:Connect(function(status,character, target,randomPoint)
        if status then 
            repeat
                task.wait(0.1)
            until  target~= nil
            local angle = randomPoint.Name == '2' and -45  or 45
            StartTrackingCam(character, target.Position, angle, 15, 12)
            TweenCameraToSubject(CenterCam, 1, 5, 6)
            -- task.wait(1)
            -- TweenCameraToSubject(character.Head, 1,20, 2)
        else
            Main.Enabled = true
            task.wait(2)
            Camera.CameraType = Enum.CameraType.Custom
        end
    end)

    StageService.WinnersStageEffect:Connect(function()
        SoundEffects.HappyCrowd:Play()
        StageEffect.Win.Enabled = true
        StageEffect.SurfaceLight.Color = Color3.fromRGB(255, 170, 0)
        StageEffect.SurfaceLight.Enabled = true
        DefaultCircularCameraMotion()
        SoundEffects.HappyCrowd:Stop()
        StageEffect.Win.Enabled = false
        StageEffect.SurfaceLight.Enabled = false
    end)
    StageService.PassedStageEffect:Connect(function()
        SoundEffects.HappyCrowd:Play()
        StageEffect.Good.Enabled = true
        StageEffect.SurfaceLight.Color = Color3.fromRGB(0,255,0)
        StageEffect.SurfaceLight.Enabled = true
        DefaultCircularCameraMotion()
        SoundEffects.HappyCrowd:Stop()
        StageEffect.Good.Enabled = false
        StageEffect.SurfaceLight.Enabled = false
    end)
    StageService.EliminatedStageEffect:Connect(function()
        SoundEffects.NegativeCartoon:Play()
        StageEffect.Bad.Enabled = true
        StageEffect.SurfaceLight.Color = Color3.fromRGB(255,0,0)
        StageEffect.SurfaceLight.Enabled = true
        DefaultCircularCameraMotion()
        SoundEffects.NegativeCartoon:Stop()
        StageEffect.Bad.Enabled = false
        StageEffect.SurfaceLight.Enabled = false
    end)
    CurrentTune = 'Normal'
    StageService.SetCamStatus:Connect(function(status, campart, playeronscale,playerweight)
        if status == 'FOVIncrease' then
            TweenService:Create(Camera, TweenInfo.new(1.5), {FieldOfView = Camera.FieldOfView - 25}):Play()
            return
        elseif status == 'FOVDecrease' then
            TweenService:Create(Camera, TweenInfo.new(1), {FieldOfView = DefaultFOV}):Play()
            return 
        end

        distance = 0
        height = 0
        if status == 'Before' then
            distance = 6
            height = 0.5
        elseif status == 'After' then
            distance = 3
            height = 0
        elseif status == 'Default' then
            distance = 5
            height = 6
        end
        if status~='cleanup' then
            if CurrentTune ~= 'StageEvent' then
                self.MusicController:PlayNewSong('StageEvent')
                CurrentTune = 'StageEvent'
            end
            -- Main.Enabled = false
            TweenCameraToSubject(campart, 1, distance, height)
        else
            TweenService:Create(Camera, TweenInfo.new(1), {FieldOfView = DefaultFOV}):Play()
            -- Main.Enabled = true
            task.wait(2)
            Camera.CameraType = Enum.CameraType.Custom
            if CurrentTune ~= 'Normal' then
                self.MusicController:PlayNewSong('Normal')
                CurrentTune = 'Normal'
            end
        end

        -- if status == 'Default' and playeronscale and playerweight then
        --     local Character = playeronscale.Character
            

            -- local TweenWeight = WeightTrove:Add(Instance.new("IntValue"))
            -- TweenWeight.Value = 0

            -- local function UpdateText(val)
            --     NewWeight.TextLabel.Text = string.format("%d lbs", val)
            -- end
            -- WeightTrove:Connect(TweenWeight:GetPropertyChangedSignal("Value"), function()
            --     UpdateText(TweenWeight.Value)
            -- end)
            
            -- TweenService:Create(TweenWeight, TweenInfo.new(7, Enum.EasingStyle.Exponential), {Value = playerweight}):Play()
            
            -- UpdateText(TweenWeight.Value)
            -- WeightTrove:Clean()
        -- end

    end)

end


return StageController