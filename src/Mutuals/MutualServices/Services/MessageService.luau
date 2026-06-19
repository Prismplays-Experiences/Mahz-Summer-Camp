local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local MessageService = Knit.CreateService({
	Name = "MessageService",
	Client = {
		SendMessage = Knit.CreateSignal(),
	},
})

function MessageService:SendToAll(text, color: Color3, font, fontSize)
	self.Client.SendMessage:FireAll(text, color, font, fontSize)
end

function MessageService:SendToPlayer(player, text, color: Color3, font, fontSize)
	self.Client.SendMessage:Fire(player, text, color, font, fontSize)
end

function MessageService:KnitInit() end
function MessageService:KnitStart() end

return MessageService
