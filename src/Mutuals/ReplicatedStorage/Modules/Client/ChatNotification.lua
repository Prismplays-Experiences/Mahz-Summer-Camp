local ChatNotification = {}

local TextChatService = game:GetService("TextChatService")
local Channel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem")

local RunService = game:GetService("RunService")

function SystemMessage(info: {})
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

function ChatNotification.new(
	Target: Player | "Server",
	text: string,
	color: Color3,
	font: Enum | string | nil,
	fontSize: number?
)
	if RunService:IsServer() then
		if Target == "Server" then
			script:WaitForChild("SendChatNoti"):FireAllClients(text, color, font, fontSize)
		else
			script:WaitForChild("SendChatNoti"):FireClient(Target, text, color, font, fontSize)
		end
		return
	end
	Channel:DisplaySystemMessage(SystemMessage({
		Text = text,
		Font = font,
		Color = color:ToHex(),
		FontSize = fontSize or 17,
	}))
end

return ChatNotification
