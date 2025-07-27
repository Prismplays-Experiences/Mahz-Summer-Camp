--> Services
----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--> Assets
----------------------------------------
local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
ReplicatedStorage:WaitForChild("Assets")
local Models = ReplicatedStorage:WaitForChild("Models")
Models:WaitForChild("SoundEffects")
local PlayerGui = Player.PlayerGui
local Main = PlayerGui:WaitForChild("Main")
local SpectateFrame = Main:WaitForChild("Spectate")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")

--> Variables
----------------------------------------
local Pos = 1

--> Knit Setup
----------------------------------------
local Spectate = Knit.CreateController({
	List = {},
	Name = "SpectateController",
})

--> Utility Functions
----------------------------------------

function CheckIfAlive(Plr)
	if not Plr.Character then
		return false
	end
	local char = Plr.Character
	if char then
		if char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0 then
			return false
		end
	end
	return true
end

--> Main Functions
----------------------------------------

function SetCam(sPlayer, Humanoid, Frame)
	if Humanoid then
		Camera.CameraSubject = Humanoid
	end
	local playerNameLabel = Frame:FindFirstChild("Player")
	if playerNameLabel then
		playerNameLabel.Text = sPlayer == Player and "YOU" or sPlayer.Name
	end
end

function UpdateViewing(Frame)
	while true do
		local sPlayer = Spectate.List[Pos]
		if not sPlayer then
			UpdateList()
			if #Spectate.List == 0 then
				return -- Stop if the list is empty
			end
			Pos = 1
		else
			if not CheckIfAlive(sPlayer) then
				table.remove(Spectate.List, table.find(Spectate.List, sPlayer))
			else
				SetCam(sPlayer, sPlayer.Character:FindFirstChild("Humanoid"), Frame)
				break
			end
		end
	end
end

function UpdateList()
	local Tab = {}
	for _, v in ipairs(game.Players:GetPlayers()) do
		local InGame = v:FindFirstChild("InGame")
		if InGame and InGame.Value then
			table.insert(Tab, v)
		end
	end
	Spectate.List = Tab
end

function Spectate:KnitStart()
	SpectateFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		if SpectateFrame.Visible then
			UpdateList()
			UpdateViewing(SpectateFrame)
		end
	end)

	local leftside = SpectateFrame:WaitForChild("left")
	local rightside = SpectateFrame:WaitForChild("right")

	leftside.MouseButton1Click:Connect(function()
		if Pos - 1 < 1 then
			Pos = #Spectate.List
		else
			Pos = Pos - 1
		end
		UpdateViewing(SpectateFrame)
	end)

	rightside.MouseButton1Click:Connect(function()
		if Pos + 1 > #Spectate.List then
			Pos = 1
		else
			Pos = Pos + 1
		end
		UpdateViewing(SpectateFrame)
	end)
end

function Spectate:Open()
	SpectateFrame.Visible = true
end

local ExperienceInfo = require("@Info/ExperienceInfo")
local TeleportService = game:GetService("TeleportService")
SpectateFrame:WaitForChild("Lobby").MouseButton1Click:Connect(function()
	TeleportService:Teleport(ExperienceInfo.Places.Lobby.Id, Player)
end)

return Spectate
