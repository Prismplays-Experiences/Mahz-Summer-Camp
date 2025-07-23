local TypingText = {}

function SoundEffect(obj)
	local Sound = Instance.new("Sound")
	Sound.Parent = obj
	Sound.Name = "TextSound"
	Sound.SoundId = "http://www.roblox.com/asset/?id=3333976425"
	Sound.PlaybackSpeed = 1.5
	Sound.Volume = 0.5
	Sound:Play()
	coroutine.resume(coroutine.create(function()
		wait(0.6)
		Sound:Destroy()
	end))
end

function TypingText.Type(textLabel, desiredtext, speed)
	local msgs = desiredtext
	speed /= #msgs
	for j = 1, #msgs do
		textLabel.Text = string.sub(msgs, 1, j)
		SoundEffect(textLabel)
		task.wait(speed)
	end
end

return TypingText
