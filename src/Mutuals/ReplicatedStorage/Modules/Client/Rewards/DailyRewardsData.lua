local DailyRewardsData = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require("@Packages/Knit")

local SoundEffects = ReplicatedStorage:WaitForChild("Models"):WaitForChild("SoundEffects")

function SendNotification(player, msg, color, duration, reward, sound)
	local Notify = Knit.GetService("NotificationService")
	Notify:SendNotification(player, {
		message = msg,
		color = color or Color3.fromRGB(255, 255, 255),
		duration = duration or 2,
		reward = reward or false,
		sound = sound or SoundEffects.Positive,
	})
end

function GiveTool(ToolName, Player)
	local ServerStorage = game:GetService("ServerStorage")
	local Tools = ServerStorage:WaitForChild("Tools")
	local Tool = Tools:FindFirstChild("ToolName")
	if Tool then
		Tool:Clone().Parent = Player.Backpack
		SendNotification(Player, `You got {ToolName}`, Color3.fromRGB(88, 255, 55), 2.5, true)
	end
end

function GiveStars(Stars, Player)
	Player.PrivateStats.Currency.Value += Stars
	SendNotification(Player, `You got {Stars} Stars!`, Color3.fromRGB(88, 255, 55), 2.5, true)
end

function GiveSpin(Spins, Player)
	Player.PrivateStats.Currency.Value += Spins
	SendNotification(Player, `You got {Spins} Spin{Spins > 1 and "s" or ""}!`, Color3.fromRGB(88, 255, 55), 2.5, true)
end

DailyRewardsData.Rewards = {
	["Day1"] = function(player)
		GiveStars(35, player)
	end,
	["Day2"] = function(player)
		GiveTool("SlappingHand", player)
	end,

	["Day3"] = function(player)
		GiveStars(75, player)
	end,
	["Day4"] = function(player)
		GiveSpin(1, player)
	end,
	["Day5"] = function(player)
		GiveTool("RainbowCarpet", player)
	end,
}

return DailyRewardsData
