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

--> Main Functions
-----------------------------------------

function IAPFunction.Client:GiveItem(Player, Item, Category)
	if Category == "Suppliments" then
		local Tool = ServerStorage.Suppliments:FindFirstChild(Item.ToolName)
		if Tool then
			local Clone = Tool:Clone()
			Clone.Parent = Player.Backpack
		else
			warn(`Item {Item.ToolName} not found in ServerStorage`)
		end
	elseif Category == "Events" then
		self.Server.MessageService:SendToAll(
			`<b> {Player.DisplayName} bought {Item.Name} event! </b>`,
			Color3.fromRGB(0, 255, 0),
			"Gotham",
			20
		)
		task.spawn(function()
			task.wait(0.1)
			self.Server.EventsService:QueueEvent(Item.EventName)
		end)
	elseif Category == "Auras" then
		local Tool = ServerStorage.Auras:FindFirstChild(Item.ToolName)
		if Tool then
			local Clone = Tool:Clone()
			Clone.Parent = Player.Backpack
		else
			warn(`Item {Item.ToolName} not found in ServerStorage`)
		end
	end
end

function IAPFunction.Client:Purchase(Player, Price, Data, Category)
	if Player.PrivateStats.Currency.Value >= Price then
		Player.PrivateStats.Currency.Value -= Price
		self:GiveItem(Player, Data, Category)
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

function IAPFunction:KnitStart()
	self.EventsService = Knit.GetService("EventsService")
	self.MessageService = Knit.GetService("MessageService")
end

return IAPFunction
