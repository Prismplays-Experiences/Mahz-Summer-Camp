--> Services
----------------------------------------
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService("TweenService")


--> Modules
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild('Packages')
local Knit = require(Packages:WaitForChild('Knit'))

local Modules = ReplicatedStorage:WaitForChild('Modules')
local TypeWriter = require(Modules:WaitForChild('Typewriter'))

--> Assets
----------------------------------------
local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local GameplayUI = PlayerGui:WaitForChild('Main'):WaitForChild('ModuleAssets')
local Transitions = GameplayUI:WaitForChild('Transitions')
local IntroFrame = Transitions:WaitForChild('IntroFrame')
local MainStatus = IntroFrame:WaitForChild('MainStatus')
local SubStatus =  IntroFrame:WaitForChild('SubStatus')

local SoundEffects = ReplicatedStorage:WaitForChild('Models'):WaitForChild('SoundEffects')


--> Variables
----------------------------------------


--> References
----------------------------------------
--[[
    -- 

]]

--> Utility Functions
----------------------------------------

function CloseIntro()
	MainStatus.Visible = false
	SubStatus.Visible = false
	IntroFrame.Logo.Visible = false

	TweenService:Create(IntroFrame:WaitForChild('UIScale'),
		TweenInfo.new(1.5,Enum.EasingStyle.Quad),
		{Scale = 0}
	):Play()
	task.wait(1.5)
	IntroFrame.Visible = false
end

function OpenIntro()
	MainStatus.Visible = false
	SubStatus.Visible = false
	IntroFrame.Visible = true

	IntroFrame:WaitForChild('UIScale').Scale = 0
	TweenService:Create(IntroFrame:WaitForChild('UIScale'),
		TweenInfo.new(1.5,Enum.EasingStyle.Quad),
		{Scale = 2}
	):Play()
	task.wait(1.5)
	IntroFrame.Logo.Visible = true
end

function WriteText(TextLabel:TextLabel, Txt, HighlightTxt)
	TextLabel.Visible = true
	TypeWriter.Type(TextLabel,Txt,1)
	
	if not HighlightTxt then return end
	TextLabel.Text = Txt .. `<font color="rgb(255,0,0)"> {HighlightTxt}</font>`
	SoundEffects:WaitForChild('Finished'):Play()
end

--> Main Functions
----------------------------------------

local TransitionController = Knit.CreateController {
	Name = 'TransitionController'
}

function TransitionController:Start(txt,subtxt)
	OpenIntro()
    if subtxt then WriteText(SubStatus,subtxt) end
	if txt then WriteText(MainStatus,txt) end

end

function TransitionController:Stop()
	PlayerGui:WaitForChild('Main'):WaitForChild('HUD').Visible = true
	CloseIntro()
end


--> Connections
----------------------------------------

--> Knit Start
----------------------------------------

function TransitionController:KnitStart()
	local TransitionService = Knit.GetService('TransitionService')
	TransitionService.SendTransition:Connect(function(txt,txt2)
		self:Start(txt,txt2)
	end)
	
	TransitionService.EndTransition:Connect(function()
		self:Stop()
	end)
end

return TransitionController