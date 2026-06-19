local ShopData = {}

local MarketService = require("@Modules/MarketService")
local MarketplaceService = game:GetService("MarketplaceService")

function GetIcon(Id)
	local Info = MarketplaceService:GetProductInfo(Id, Enum.InfoType.GamePass)
	return Info.IconImageAssetId
end

ShopData.GamepassItems = {}

for _, v in MarketService.GamepassIds do
	ShopData.GamepassItems[v.Id] = {
		Name = "_",
		Id = v.Id,
		ToolName = v.ToolName,
		Icon = v.Icon or GetIcon(v.Id) or "rbxassetid://1234567890", -- Default icon if not provided
	}
end

ShopData.ProductItems = {}

return ShopData
