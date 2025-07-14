--> Services
----------------------------------------
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')

--> Modules
----------------------------------------
local TypeWriter = require(script.Parent:WaitForChild('Typewriter'))

--> Assets
----------------------------------------

--> Variables
----------------------------------------

--> References
----------------------------------------
--[[
    -- 

]]

--> Utility Functions
----------------------------------------

local function StringHasNumber(str) : boolean
	return string.match(str, "%d") ~= nil
end


local function openFrame(frame)
	frame.Position = UDim2.new(0.5, 0, 1.2, 0)

	local goal = { Position = UDim2.new(0.5, 0, 0.7, 0) }
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(frame, tweenInfo, goal):Play()
end

local function closeFrame(frame)
	local goal = { Position = UDim2.new(0.5, 0, -0.5, 0) }
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	TweenService:Create(frame, tweenInfo, goal):Play()
end

local function pulse(frame)
	local scaleTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local scaleUp = TweenService:Create(frame, scaleTweenInfo, { Size = frame.Size + UDim2.new(0, 20, 0, 20) })
	local scaleDown = TweenService:Create(frame, scaleTweenInfo, { Size = frame.Size })

	scaleUp:Play()
	scaleUp.Completed:Connect(function()
		scaleDown:Play()
	end)
end

--> Main Functions
----------------------------------------
local HardNotification = {}

function HardNotification.Send(Player, Txt, Image, SoundEffect,DELAY)
	local Main = Player.PlayerGui:FindFirstChild('Main')
    local ModuleAssets = Main:WaitForChild('ModuleAssets')
	local Template = ModuleAssets.HardNotification:Clone()

	
	if StringHasNumber(Image) then
		Template.ImageIcon.Visible = true
		Template.EmojiIcon.Visible = false
		Template.ImageIcon.Image = Image
		
	else
		Template.ImageIcon.Visible = false
		Template.EmojiIcon.Visible = true
		Template.EmojiIcon.Text = Image
	end
	
	Template.TextLabel.Text = ''
	
	openFrame(Template)
	Template.Parent = Player.PlayerGui:FindFirstChildWhichIsA('ScreenGui')
	if SoundEffect then
		SoundEffect:Play()
	end
	task.wait(0.1)
	pulse(Template)
	TypeWriter.Type(Template.TextLabel,Txt,1)
	
	task.wait(1)
	if DELAY then
		task.wait(DELAY)
	end
	closeFrame(Template)
	
	task.delay(10,function()
		Template:Destroy()
	end)
end


return HardNotification
