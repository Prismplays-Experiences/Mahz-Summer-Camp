--> Modules
-----------------------------------------
local Knit = require("@Packages/Knit")
local IAPDATA = require("@Info/IAPDATA")

--> Assets
-----------------------------------------
local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local Main = PlayerGui:WaitForChild("Main")
local CoreFrames = Main:WaitForChild("Core")
local EventsDisplay = CoreFrames:WaitForChild("EventsDisplay")

local SupplimentsDisplayTemplate = PlayerGui:WaitForChild("Templates"):WaitForChild("SupplimentsDisplayTemplate")

--> Knit Setup
-----------------------------------------
local SupplimentsController = Knit.CreateController({
	Name = "SupplimentsController",
})

function TimeToString(Time)
	local minutes = math.floor(Time / 60)
	local seconds = Time % 60
	return string.format("%02d:%02d", minutes, seconds)
end

function CreatSupplimentsDisplay(ItemName)
	local Suppliment = IAPDATA.Suppliments[ItemName]
	if Suppliment then
		local NewTemp = SupplimentsDisplayTemplate:Clone()
		NewTemp.Name = ItemName
		NewTemp.Parent = EventsDisplay
		NewTemp.Visible = true
		NewTemp.Image = Suppliment.Image
		return NewTemp
	end
	return nil
end

function SupplimentsController:KnitStart()
	self.SuplimentsService = Knit.GetService("SupplimentsService")
	self.SuplimentsService.UseSuppliment:Connect(function(ItemName, Time)
		local NewTemp = CreatSupplimentsDisplay(ItemName)
		for i = 1, Time do
			NewTemp.Time.Text = TimeToString(Time - i)
			task.wait(1)
		end
		NewTemp.Visible = false
	end)
end

return SupplimentsController
