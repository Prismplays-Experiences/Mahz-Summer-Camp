local WheelData = {}

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Models = ReplicatedStorage:WaitForChild('Models')
local SoundEffects = Models:WaitForChild('SoundEffects')

local Knit = require(ReplicatedStorage:WaitForChild('Packages'):WaitForChild('Knit'))
local Modules = ReplicatedStorage:WaitForChild('Modules')
local ChatNotification = require(Modules.Client.ChatNotification)

function SendNotification(player,msg,color,duration,reward,sound)
    local Notify = Knit.GetService('NotificationService')
    Notify:SendNotification(player,{
        message = msg,
        color = color or Color3.fromRGB(255, 255, 255),
        duration = duration or 2,
        reward = reward or false,
        sound = sound or SoundEffects.Positive})
end

function DefaultWinEvent(Player,Msg,Msg2)
	local Notify = Knit.GetService('NotificationService')
	Notify:SendNotification(Player,{
		message = Msg or 'You won a reward!',
		color = Color3.fromRGB(40, 217, 0),
		duration = 2,
		reward = true,
		sound = SoundEffects.TreasureCollect})

	if Msg2 then
		Announce(Msg2)
	end
end

function Announce(txt)
	ChatNotification.new('Server',txt, Color3.fromRGB(182, 218, 0),'Roboto')
end


WheelData.WheelValues = {
	[1] = {Name = 'Currency', Value = 5000},
	[2] = {Name = 'Currency', Value = 500},
	[3] = {Name = 'Lifes', Value = 1},
	[4] = {Name = 'Lifes', Value = 5},
	[5] = {Name = 'Currency', Value = 150 },
	[6] = {Name = 'Lifes', Value = 3},
}

WheelData.Chances = {
	[1] = 1,
	[2] = 22,
	[3] = 25,
	[4] = 12,
	[5] = 25,
	[6] = 15,
}

WheelData.Data = {
	[1] = {
		Reward = function(Player)
			local val = WheelData.WheelValues[1].Value
			Player.PrivateStats.Currency.Value += val
			DefaultWinEvent(Player, `You won {val} Coins!`)
		end,
	};
	[2] = {
		Reward = function(Player)
			local val = WheelData.WheelValues[2].Value
			Player.PrivateStats.Currency.Value += val
			DefaultWinEvent(Player, `You won {val} Coins!`)
		end,
	};
	[3] = {
		Reward = function(Player)
			local val = WheelData.WheelValues[3].Value
			Player.PrivateStats.Lifes.Value += val
			DefaultWinEvent(Player, `You won {val} Lifes!`)
		end,
	};
	[4] = {
		Reward = function(Player)
			local val = WheelData.WheelValues[4].Value
			Player.PrivateStats.Currency.Value += val
			DefaultWinEvent(Player, `You won {val} Lifes!`)
		end,
	};
	[5] = {
		Reward = function(Player)
			local val = WheelData.WheelValues[5].Value
			Player.PrivateStats.Currency.Value += val
			DefaultWinEvent(Player, `You won {val} Coins!`)
		end,
	};
	[6] = {
		Reward = function(Player)
			local val = WheelData.WheelValues[6].Value
			Player.PrivateStats.Lifes.Value += val
			DefaultWinEvent(Player, `You won {val} Lifes!`)
		end,
	};

}

return WheelData