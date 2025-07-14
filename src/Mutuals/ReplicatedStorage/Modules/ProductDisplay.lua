--> Services
----------------------------------------
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
--> Modules
----------------------------------------

--> Assets
----------------------------------------
local Player = game.Players.LocalPlayer

local GameMap = workspace:WaitForChild("Game")
-- local ProductDisplay = GameMap:WaitForChild('ScriptingProperties'):WaitForChild("ProductDisplay")


--> Variables
----------------------------------------
local ProductDisplayModule = {}
-- local MaxSpots = #ProductDisplay:GetChildren()
local SpotCount = 0




--> Utility Functions
----------------------------------------
local function SpinAndBob(Model, height, spinSpeed)
    if not Model or not Model:IsA("Model") then return end

    local pivotCFrame = Model:GetPivot()
    local timeElapsed = 0
    height = height or 1.2
    spinSpeed = spinSpeed or 0.5

    local Connection
    Connection = RunService.Heartbeat:Connect(function(deltaTime)
        timeElapsed = timeElapsed + deltaTime
        local bobOffset = math.abs(math.sin(timeElapsed * spinSpeed)) * height
        local angle = timeElapsed * spinSpeed

        Model:PivotTo(
            pivotCFrame
            * CFrame.new(0, bobOffset, 0)
            * CFrame.Angles(0, angle, 0)
        )
    end)

    return function()
        if Connection then
            Connection:Disconnect()
            Connection = nil
        end
    end
end

local function Bob(Model, height, bobSpeed)
    if not Model or not Model:IsA("Model") then return end

    local pivotCFrame = Model:GetPivot()
    local timeElapsed = 0
    height = height or 0.02
    bobSpeed = bobSpeed or 0.5

    local Connection
    Connection = RunService.Heartbeat:Connect(function(deltaTime)
        timeElapsed = timeElapsed + deltaTime
        local bobOffset = math.abs(math.sin(timeElapsed * bobSpeed)) * height

        Model:PivotTo(
            pivotCFrame
            * CFrame.new(0, bobOffset, 0)
        )
    end)

    return function()
        if Connection then
            Connection:Disconnect()
            Connection = nil
        end
    end
end

local function Spin(Model, spinSpeed)
    if not Model or not Model:IsA("Model") then return end

    local pivotCFrame = Model:GetPivot()
    local timeElapsed = 0
    spinSpeed = spinSpeed or 0.5

    local Connection
    Connection = RunService.Heartbeat:Connect(function(deltaTime)
        timeElapsed = timeElapsed + deltaTime
        local angle = timeElapsed * spinSpeed

        Model:PivotTo(
            pivotCFrame
            * CFrame.Angles(0, angle, 0)
        )
    end)

    return function()
        if Connection then
            Connection:Disconnect()
            Connection = nil
        end
    end
end


local MoveSet = {
    Spin = Spin,
    SpinAndBob = SpinAndBob,
    Bob = Bob,
}

local Points = {}

RunService.RenderStepped:Connect(function()
    pcall(function()
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        for _, point in Points do
            local Dist = (point.Pos.Position - Player.Character.HumanoidRootPart.Position).Magnitude
            if Dist < 6 then
            point.Signal()
            end
        end
    end)

end)


function NewProductDisplay(model, id, itemType, movement)
    -- if SpotCount >= MaxSpots then return end

    local price
    local signal

    if itemType == "Product" then
        signal = function()
            MarketplaceService:PromptProductPurchase(Player, id)
        end
        local marketInfo = MarketplaceService:GetProductInfo(id, Enum.InfoType.Product)
        price = marketInfo.PriceInRobux
    else
        if not RunService:IsStudio() and MarketplaceService:UserOwnsGamePassAsync(Player.UserId, id) then
            return
        end
        signal = function()
            MarketplaceService:PromptGamePassPurchase(Player, id)
        end
        local marketInfo = MarketplaceService:GetProductInfo(id, Enum.InfoType.GamePass)
        price = marketInfo.PriceInRobux
    end

    SpotCount += 1
    local spot = ProductDisplay[SpotCount]

    spot:WaitForChild('Pos').Transparency = 1
    spot:WaitForChild('Pos').CanCollide = false

    local clonedModel = model:Clone()
    clonedModel.Parent = spot
    clonedModel:MoveTo(spot:WaitForChild('Pos').Position)

    if movement then
        task.spawn(MoveSet[movement], clonedModel)
    end

    local point = {
        Pos =  spot.Pos,
        Signal = signal,
    }
    Points[SpotCount] = point
end


--> Main Functions
----------------------------------------
function ProductDisplayModule.new(dataset)
    for _,data in pairs(dataset) do
        if data.model and data.id and data.itemType then
            NewProductDisplay(data.model, data.id, data.itemType, data.movement)
        end
    end

end

return ProductDisplayModule
