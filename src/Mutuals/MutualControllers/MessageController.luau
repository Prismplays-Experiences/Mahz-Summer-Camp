local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local TextChannels = TextChatService:WaitForChild("TextChannels")
local Channel: TextChannel = TextChannels:WaitForChild("RBXSystem")
local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

local MessageController = Knit.CreateController({
	Name = "MessageController",
})

function SystemMessage(info)
	return '<font color="#'
		.. info["Color"]
		.. '"><font size="'
		.. info["FontSize"]
		.. '"><font face="'
		.. info["Font"]
		.. '">'
		.. info["Text"]
		.. "</font></font></font>"
end

function MessageController:DisplayMessage(text, color: Color3, font, fontSize)
	Channel:DisplaySystemMessage(SystemMessage({
		Text = text,
		Font = font,
		Color = color:ToHex(),
		FontSize = fontSize or 17,
	}))
end

function MessageController:KnitStart()
	local MessageService = Knit.GetService("MessageService")
	MessageService.SendMessage:Connect(function(text, color: Color3, font, fontSize)
		self:DisplayMessage(text, color, font, fontSize)
	end)
end

return MessageController
