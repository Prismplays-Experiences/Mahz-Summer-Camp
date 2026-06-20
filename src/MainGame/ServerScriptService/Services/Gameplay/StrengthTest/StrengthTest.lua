--> Services
----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")
local GeneralInfo = require("@Info/GeneralInfo")
local InstructorMessages = require("@Info/InstructorMessages")

--> Constants
----------------------------------------

--> Assets
----------------------------------------

local Models = ReplicatedStorage:WaitForChild("Models")
local ScaleStrength = Models:WaitForChild("ScaleStrength")
local SoundEffects = Models:WaitForChild("SoundEffects")

local Assets = ServerStorage.Assets

--> Variables
----------------------------------------

--> Knit Setup
----------------------------------------
local StrengthTestService = Knit.CreateService({
	Name = "StrengthTestService",
	StageEventRunning = false,
	Client = {},
})

--> Utility Functions
----------------------------------------

function DeepCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		if type(value) == "table" then
			value = DeepCopy(value)
		end
		copy[key] = value
	end
	return copy
end

return StrengthTestService
