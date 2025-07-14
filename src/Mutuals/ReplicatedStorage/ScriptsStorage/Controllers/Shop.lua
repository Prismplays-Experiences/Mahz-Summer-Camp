--> Services
----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")


--> Knit Setup
----------------------------------------
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
local ShopController = Knit.CreateController { 
    Name = "ShopController" ,
}

--> Modules
----------------------------------------
local Modules = ReplicatedStorage:WaitForChild("Modules")
local ShopData = require(Modules:WaitForChild('Client')
                                :WaitForChild("Info")
                                :WaitForChild("ShopData"))

--> Assets
----------------------------------------        
local SoundEffects = ReplicatedStorage:WaitForChild("Models"):WaitForChild("SoundEffects")             

local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local ShopFrame = PlayerGui:WaitForChild("Main"):WaitForChild("Frames"):WaitForChild("Shop")
local ShopContainer = ShopFrame:WaitForChild("Container")
local ItemTemplate = ShopContainer:WaitForChild("ItemTemplate")

--> Utility Functions
----------------------------------------

function GetPrice(Id,Type)
    local success, result = pcall(function()
        if Type == "Gamepass" then
            return MarketplaceService:GetProductInfo(Id, Enum.InfoType.GamePass)
        elseif Type == "Product" then
            return MarketplaceService:GetProductInfo(Id, Enum.InfoType.Product)
        end
    end)

    if not success then
        warn("Failed to get product info: " .. result)
        return nil
    end

    return result.PriceInRobux or 0
end



function ClearChildren(Parent)
    for _, child in ipairs(Parent:GetChildren()) do
        if child:IsA('GuiObject') then 
            child:Destroy()
        end
    end
end

function SendNotification(msg,color,duration,reward,sound)
    local Notify = Knit.GetController('UINotificationsController')
    Notify:ShowNotification({
        message = msg,
        color = color or Color3.fromRGB(255, 255, 255),
        duration = duration or 2,
        reward = reward or false,
        sound = sound or SoundEffects.Positive})
end


local function GamepassOwned(Id)
    local success, result = pcall(function()
        return game:GetService("MarketplaceService"):UserOwnsGamePassAsync(game.Players.LocalPlayer.UserId, Id)
    end)
    if not success then
        warn("Failed to check game pass ownership: " .. result)
        return false
    end
    return result
end

function ShopController:PromptItemPurchase(Button,Id,Gamepass,ToolName)
    if GamepassOwned(Id) then
        Button.Text = "Equip"
        Button.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
        Button.AutoButtonColor = false
        -- Button.MouseButton1Click:Connect(function()
        --     SendNotification( 
        --         "You already own this item!", 
        --         Color3.fromRGB(255, 0, 0), 
        --         2, 
        --         false, 
        --         SoundEffects.UIDeny)
        -- end)
        -- return
    else

        Button.Text = utf8.char(0xE002)..GetPrice(Id, Gamepass and "Gamepass" or "Product")
    end

    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
        if player == game.Players.LocalPlayer and gamePassId == Id then
            if wasPurchased then
                Button.Text = "Equip"
                Button.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
                Button.AutoButtonColor = false
            end
        end
    end)


    
    Button.MouseButton1Click:Connect(function()
        if GamepassOwned(Id) and ToolName then
            self.InventoryService:EquipTool(ToolName):andThen(function(result)
                if result then
                    SendNotification(result, Color3.fromRGB(0, 255, 0), 2)
                else
                    SendNotification("Failed to equip tool.", Color3.fromRGB(255, 0, 0), 2, false, SoundEffects.UIDeny)
                end
            end)
            return
        end
        if Gamepass then
            local success, errorMessage = pcall(function()
                game:GetService("MarketplaceService"):PromptGamePassPurchase(game.Players.LocalPlayer, Id)
            end)
            if not success then
                warn("Failed to prompt game pass purchase: " .. errorMessage)
            end
        else
            local success, errorMessage = pcall(function()
                game:GetService("MarketplaceService"):PromptProductPurchase(game.Players.LocalPlayer, Id)
            end)
            if not success then
                warn("Failed to prompt product purchase: " .. errorMessage)
            end
        end
    end)
end


--> Main Function
----------------------------------------

function ShopController:Blub() --KnitStart()

    self.InventoryService = Knit.GetService("InventoryService")

    local Template = ItemTemplate:Clone()
    ClearChildren(ShopContainer)
    for _, item in pairs(ShopData.GamepassItems) do
        local Item = Template:Clone()
        Item.Name = item.Name
        Item.ItemName.Text = item.Name
        Item.Buy.Text = utf8.char(0xE002)..tostring(item.Price)
        Item.Icon.Image =  `rbxassetid://{item.Icon}`
        self:PromptItemPurchase(Item.Buy, item.Id, true, item.ToolName)

        Item.Parent = ShopContainer
    end
end

return ShopController