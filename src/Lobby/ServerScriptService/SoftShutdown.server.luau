local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local placeId = require("@Info/PlaceId").Get()

if game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0 then
	-- this is a reserved server without a VIP server owner
	local m = Instance.new("Message")
	m.Text = "This is a temporary lobby. Teleporting back in a moment."
	m.Parent = workspace

	local waitTime = 5

	Players.PlayerAdded:connect(function(player)
		wait(waitTime)
		waitTime = waitTime / 2
		TeleportService:Teleport(placeId, player)
	end)

	for _, player in pairs(Players:GetPlayers()) do
		TeleportService:Teleport(placeId, player)
		wait(waitTime)
		waitTime = waitTime / 2
	end
else
	game:BindToClose(function()
		if #Players:GetPlayers() == 0 then
			return
		end

		if game:GetService("RunService"):IsStudio() then
			return
		end

		local m = Instance.new("Message")
		m.Text = "Rebooting servers for update. Please wait"
		m.Parent = workspace
		wait(2)
		local reservedServerCode = TeleportService:ReserveServer(placeId)

		for _, player in pairs(Players:GetPlayers()) do
			TeleportService:TeleportToPrivateServer(placeId, reservedServerCode, { player })
		end
		Players.PlayerAdded:connect(function(player)
			TeleportService:TeleportToPrivateServer(placeId, reservedServerCode, { player })
		end)
		while #Players:GetPlayers() > 0 do
			wait(1)
		end

		-- done
	end)
end
