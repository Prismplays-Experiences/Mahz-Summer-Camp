local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

local InfluencerModule = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("InfluencerData"))

TextChatService.OnIncomingMessage = function(message: TextChatMessage)
	local Properties = Instance.new("TextChatMessageProperties")

	if message.TextSource and message.TextSource.UserId then
		local Player = Players:GetPlayerByUserId(message.TextSource.UserId)

		if Player then
			local GamepassFolder = Player:FindFirstChild("GamepassFolder")
			local VIP = GamepassFolder and GamepassFolder:FindFirstChild("VIP")
			if
				table.find(InfluencerModule.Admin, Player.UserId)
				or table.find(InfluencerModule.Moderators, Player.UserId)
			then
				Properties.PrefixText = "<font color='#66ff00'>[STAFF]</font> " .. message.PrefixText
			else
				if VIP and VIP.Value then
					Properties.PrefixText = "<font color='#FFC800'>[VIP]</font> " .. message.PrefixText
				end
			end
		end
	end

	return Properties
end
