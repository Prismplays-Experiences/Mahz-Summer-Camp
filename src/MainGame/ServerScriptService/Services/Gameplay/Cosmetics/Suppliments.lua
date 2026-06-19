--> Modules
-----------------------------------------
local Knit = require("@Packages/Knit")
--> Knit Setup
-----------------------------------------
local SupplimentsService = Knit.CreateService({
	Name = "SupplimentsService",
	Client = {
		UseSuppliment = Knit.CreateSignal(),
		UseDailyBoost = Knit.CreateSignal(),
	},
})

function SupplimentsService:UseSuppliment(Player, Tool, Time)
	if not Tool then
		return
	end
	local ItemName = Tool.Name
	Player:AddTag(ItemName)
	self.Client.UseSuppliment:Fire(Player, ItemName, Time)
	task.delay(Time, function()
		Player:RemoveTag(ItemName)
	end)
end

function SupplimentsService:RecoverHealth(Player, Amount)
	self.GeneralService.Client.InjuredCount:SetFor(
		Player,
		self.GeneralService.Client.InjuredCount:GetFor(Player) - Amount
	)
end

function SupplimentsService:KnitStart()
	self.GeneralService = Knit.GetService("GeneralGameplay")
end

return SupplimentsService
