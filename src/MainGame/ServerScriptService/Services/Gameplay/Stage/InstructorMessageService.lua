--> Services
----------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService('ServerStorage')
-- local RunService = game:GetService("RunService")

--> Modules
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Signal = require(Packages:WaitForChild("Signal"))
local Knit = require(Packages:WaitForChild("Knit"))

local Info = ReplicatedStorage:WaitForChild("Info")
local InstructorMessages = require(Info:WaitForChild("InstructorMessages"))

--> Assets
----------------------------------------
local ScriptingProperties = workspace:WaitForChild("Game"):WaitForChild("ScriptingProperties")
local InstructorHolder = ScriptingProperties:WaitForChild("InstructorHolder")
local Instructor = ServerStorage:WaitForChild('Assets'):WaitForChild("Instructor")
local CenterPoint = InstructorHolder:WaitForChild("Center")

--> Variables
----------------------------------------


--> Knit Setup
----------------------------------------
local InstructorMessage = Knit.CreateService {
    Name = "InstructorMessage",
    MessageEnded = Signal.new(),
    Client = {
        CameraControl = Knit.CreateUnreliableSignal(),
    }
}


--> Utility Functions
----------------------------------------
function PickRandomPoint(Folder)
    local Children = Folder:GetChildren()
    if #Children == 0 then
        return nil
    end
    return Children[math.random(1, #Children)]
end

function PivotToSpot(Character,target)
    Character:PivotTo(target.CFrame * CFrame.new(0, 3, 0))
end

function WalktoSpot(Character,target, PivotAfter)
		
	-- StopAllAnimations(p)
    for i = 1,#target do
        while task.wait(0.1) do
            local Humanoid:Humanoid = Character.Humanoid
            Humanoid.WalkSpeed = 16
            Humanoid:MoveTo(target[i].Position)
            Humanoid.MoveToFinished:Wait()
            Humanoid.WalkSpeed = 0
            if (Character.HumanoidRootPart.Position - target[i].Position).Magnitude < 5 then
                break
            end
        end
    end
    if PivotAfter then
        PivotToSpot(Character, target[#target])
    end

end
--> Main Functions
----------------------------------------



function InstructorMessage:PlayMessage(Message)
    self.NewInstructor = Instructor:Clone()
    self.NewInstructor.Parent = InstructorHolder
    local randomPoint = PickRandomPoint(InstructorHolder.TargetPoints)
    if randomPoint then
        self.NewInstructor:PivotTo(randomPoint.CFrame * CFrame.new(0, 4, 0))
    end
    task.wait(2)
    self.Client.CameraControl:FireAll(true, self.NewInstructor, CenterPoint,randomPoint,Message)
    WalktoSpot(self.NewInstructor, {randomPoint['1'],randomPoint['2'], CenterPoint}, true)
    task.spawn(function()
        task.wait(35)
        self.NewInstructor:Destroy()
    end)
end


function InstructorMessage:KnitStart()
    self.MusicService = Knit.GetService('MusicService')
    -- for i = 1,10 do
    --     task.wait(1)
    --     print("Instructor Message: " .. i)
    -- end
    -- self:PlayMessage(InstructorMessages.Intro)
end

return InstructorMessage