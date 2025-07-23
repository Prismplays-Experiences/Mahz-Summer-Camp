--> Services
----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")
local HardNotification = require("@Modules/HardNotification")

--. Assets
----------------------------------------
local Player = game.Players.LocalPlayer
local Assets = ReplicatedStorage:WaitForChild("Assets")
Assets:WaitForChild("Confetti")

local PlayerGui = Player.PlayerGui
local Main = PlayerGui:WaitForChild("Main")
local EventsInterfaces = Main:WaitForChild("EventsInterfaces")
local CoreFrames = Main:WaitForChild("Core")
local HUD = Main:WaitForChild("HUD")
local EventTxt = CoreFrames:WaitForChild("Event")

local Models = ReplicatedStorage:WaitForChild("Models")
local SoundEffects = Models:WaitForChild("SoundEffects")

--> Knit Setup
----------------------------------------
local EventsController = Knit.CreateController({
	Name = "EventsController",
})

--> Utility Functions
----------------------------------------

function EnableFrame(Frames, TargetFrame)
	for _, frame in Frames:GetChildren() do
		if frame:IsA("Frame") then
			if frame.Name == TargetFrame then
				frame.Visible = true
			else
				frame.Visible = false
			end
		end
	end
end

--> Main Functions
----------------------------------------

function EventsController:KnitStart()
	self.EventsService = Knit.GetService("EventsService")

    self.EventsService.EnableEventsInterfaces:Connect(function(status, frame)
        if status then
            HUD.Visible = true
            CoreFrames.Visible = false
            EventsInterfaces.Visible = true
            EnableFrame(EventsInterfaces, frame)
        else
            -- HUD.Visible = true
            CoreFrames.Visible = true
            EventsInterfaces.Visible = false
        end
    end)

	self.EventsService.EventStatus:Observe(function(txt)
		EventTxt.Text = txt
	end)

	self.EventsService.SendHardNotification:Connect(function(txt, Image)
		HardNotification.Send(Player, txt, Image, SoundEffects.FoodReady, 2.5)
	end)
end

return EventsController
