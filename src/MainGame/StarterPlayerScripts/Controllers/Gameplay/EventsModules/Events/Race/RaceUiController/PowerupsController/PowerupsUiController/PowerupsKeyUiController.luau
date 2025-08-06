local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local RaceInfo = require("@Info/Events/RaceInfo")
local Knit = require("@Packages/Knit")
local types = require("../../../types")

type PowerupsKeyUiController = types.PowerupsKeyUiController

local player = Players.LocalPlayer

local KEY_CODE_LABEL = RaceInfo.ui.powerupKeyCodeLabel(player)

local PowerupsKeyUiController = Knit.CreateController({
	Name = "PowerupsKeyUiController",
})

function PowerupsKeyUiController.KnitInit()
	local platform = ""

	if UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
		platform = "Q to use"
	elseif UserInputService.GamepadEnabled then
		platform = "LB to use"
	end

	KEY_CODE_LABEL.Text = platform
end

return PowerupsKeyUiController
