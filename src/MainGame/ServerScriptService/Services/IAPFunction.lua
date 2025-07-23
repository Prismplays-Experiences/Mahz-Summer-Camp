--> Services
-----------------------------------------
local ServerStorage = game:GetService("ServerStorage")

--> Modules
-----------------------------------------
local Knit = require("@Packages/Knit")
local IAPDATA = require("@Info/IAPDATA")

--> Knit Setup
-----------------------------------------
local IAPFunction = Knit.CreateService({
	Name = "IAPFunction",
	Client = {},
})

--> Utility Functions
-----------------------------------------
function GiveItem(Player, Item)
	local Tool = ServerStorage.Suppliments:FindFirstChild(Item)
	if Tool then
		local Clone = Tool:Clone()
		Clone.Parent = Player.Backpack
	else
		warn(`Item {Item} not found in ServerStorage`)
	end
end

--> Main Functions
-----------------------------------------

function IAPFunction.Client:Purchase(Player, Item)
	local Data = IAPDATA.Suppliments[Item]
	local Price = Data.Cost
	if Player.PrivateStats.Currency.Value >= Price then
		Player.PrivateStats.Currency.Value -= Price
		GiveItem(Player, Item)
		return true, "Purchase successful"
	else
		return false, "Not enough currency"
	end
end

function IAPFunction.Client:UseSuppliment(Player, Tool)
	if not Tool then
		return
	end
	Tool:Destroy()
	local Func = IAPDATA.Suppliments[Tool.Name].func
	Func(Player)
end

return IAPFunction
