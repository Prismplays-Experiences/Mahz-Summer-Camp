local Obstacles = {}

local CollectionService = game:GetService("CollectionService")

function Obstacles.RotatingPart(killPart)
    local angularVelocity = killPart:GetAttribute("AngularVelocity") or 1.5
    local axis = killPart:GetAttribute("Axis") or Vector3.new(0, 1, 0)
    if not killPart then
        warn("Missing killPart")
        return
    end

    -- Create the base part
    local basePart = Instance.new("Part")
    basePart.Size = Vector3.new(1, 1, 1)
    basePart.Anchored = true
    basePart.CanCollide = false
    basePart.Transparency = 1
    basePart.Name = "RotationBase"
    basePart.CFrame = killPart.CFrame -- Align with kill part
    basePart.Parent = killPart.Parent

    -- Create Attachments
    local baseAttachment = Instance.new("Attachment")
    baseAttachment.Name = "BaseAttachment"
    baseAttachment.Position = Vector3.zero
    baseAttachment.Axis = axis or Vector3.new(0, 1, 0)
    baseAttachment.Parent = basePart

    local killAttachment = Instance.new("Attachment")
    killAttachment.Name = "KillAttachment"
    killAttachment.Position = Vector3.zero
    killAttachment.Axis = axis or Vector3.new(0, 1, 0)
    killAttachment.Parent = killPart

    -- Create HingeConstraint
    local hinge = Instance.new("HingeConstraint")
    hinge.Name = "KillHinge"
    hinge.Attachment0 = killAttachment
    hinge.Attachment1 = baseAttachment
    hinge.ActuatorType = Enum.ActuatorType.Motor
    hinge.AngularVelocity = angularVelocity or 5
    hinge.MotorMaxTorque = math.huge
    hinge.Parent = killPart

    -- Ensure correct anchoring
    killPart.Anchored = false

end

function Obstacles.killPart(killPart)
    if not killPart then
        warn("Missing killPart")
        return
    end
    local Debounces = {}
    killPart.Touched:Connect(function(hit)
       
        local character = hit.Parent
        if Debounces[character] then
            return -- Prevent multiple triggers for the same character
        end
        Debounces[character] = true -- Set debounce for this character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid:TakeDamage(killPart:GetAttribute('HealthDamage') or 50) -- Damage the player
        end
        task.wait(1) -- Reset debounce after a short delay
        Debounces[character] = nil -- Clear the debounce for this character
    end)
end

local Tags = {
    {Tag = 'Killpart', Function = Obstacles.killPart},
    {Tag = 'SpinLaser', Function = Obstacles.RotatingPart},
}

local function getTaggedFromFolder(folder, tag)
    local tagged = CollectionService:GetTagged(tag)
    local result = {}

    for _, instance in ipairs(tagged) do
        if instance:IsDescendantOf(folder) then
            table.insert(result, instance)
        end
    end

    return result
end


function Obstacles.ApplyObstacles(Model)
    -- if not Model or not Model:IsA("Model") or not Model:IsA('Folder') then
    --     warn("Invalid model/folder provided")
    --     return
    -- end

    for _, tagInfo in ipairs(Tags) do
        local taggedParts = getTaggedFromFolder(Model, tagInfo.Tag)
        for _, part in ipairs(taggedParts) do
            tagInfo.Function(part)
        end
    end

    -- Optionally, you can add more functionality here to handle the model further.
end



return Obstacles