--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")

--> NotificationsService
----------------------------------------
local NotificationsService = Knit.CreateService({
	Name = "NotificationService",
	Client = {
		SendNotification = Knit.CreateSignal(),
	},
})

-- Send a notification to a specific player.
-- data is a table with these fields:
-- message, color, duration, frameName, reward, sound, noDuplicates — "Avoid duplicate notifications."
function NotificationsService:SendNotification(player, data)
	self.Client.SendNotification:Fire(player, data)
end

-- Request notification from client
--function NotificationsService.Client:RequestNotification(player, data)
--	self:SendNotification(player, data)
--end

return NotificationsService
