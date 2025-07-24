--> Services
----------------------------------------
local Players = game:GetService("Players")

--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")
local Trove = require("@Packages/Trove")

--> Variables
----------------------------------------
local ScriptingProperties = workspace:WaitForChild("Game"):WaitForChild("ScriptingProperties")
local Beds = ScriptingProperties:WaitForChild("Beds")

local SleepTime = 7
local SeatsTrove = Trove.new()

local SoundEffects = game.ReplicatedStorage.Models.SoundEffects

--> References
----------------------------------------
--[[
	-- BedNumber is the number of bed the player sleeps in.

]]

--> Utility Functions
----------------------------------------

function TeleportPlayersToBed(playersForTeleportation: {})
	for _, plr in pairs(playersForTeleportation) do
		task.spawn(function() -- avoid loop break when theres an error
			local SleepPart = Beds:FindFirstChild(plr:GetAttribute("BedNumber"))
			-- local SleepPart = PlayerBed:FindFirstChild('SleepPart')
			plr:SetAttribute("HipHight", plr.Character.Humanoid.HipHeight)
			local NewSeat: Seat = SeatsTrove:Add(Instance.new("Seat"))
			NewSeat.Transparency = 1
			NewSeat.Disabled = true
			NewSeat.Anchored = true
			NewSeat.CFrame = SleepPart.CFrame
			plr.Character.Humanoid.HipHeight = 0
			NewSeat.Parent = Beds
			local Character = plr.Character
			local Humanoid = Character.Humanoid
			Humanoid.WalkSpeed = 0
			Humanoid.JumpPower = 0
			NewSeat:Sit(Character.Humanoid)
		end)
	end
end

--> Main Functions
----------------------------------------
local BedService = Knit.CreateService({
	Name = "BedService",
	Client = {
		SleepAnim = Knit.CreateSignal(),
	},
})

function BedService:AssignBedNumbers(playersForBeds: {})
	for i, v in playersForBeds do
		v:SetAttribute("BedNumber", i) -- i
	end
end

function BedService:SleepPlayers(Auto, halt) -- Makes player sleep, Auto ensures players automaticall get up
	if not self.BedAssigned then
		self:AssignBedNumbers(game.Players:GetPlayers())
		self.BedAssigned = true
	end

	self.EndTransition = self.TransitionService:SendTransitionAll("BedTime.")

	task.wait(1)

	TeleportPlayersToBed(Players:GetPlayers())
	self.Client.SleepAnim:FireAll(true)

	if not Auto then
		return
	end
	if halt then
		task.wait(SleepTime)
		self:RisePlayers()
	else
		task.delay(SleepTime, function()
			self:RisePlayers()
		end)
	end
	--
end

function BedService:RisePlayers() -- Makes player awake
	SoundEffects.Referee:Play()
	self.EndTransition:FireAll()
	task.wait(1)
	self.Client.SleepAnim:FireAll(false)
	task.wait(3)

	for _, plr in pairs(Players:GetChildren()) do
		task.spawn(function()
			local character = plr.Character
			local Humanoid = character.Humanoid
			Humanoid.WalkSpeed = 16
			Humanoid.JumpPower = 50
			Humanoid.HipHeight = plr:GetAttribute("HipHight") or 0

			-- local PlayerBed = Beds:FindFirstChild(plr:GetAttribute('BedNumber'))
			-- local ArisePart = PlayerBed:FindFirstChild('ArisePart')

			-- character:MoveTo(ArisePart.Position+Vector3.new(0,3,0))
		end)
	end
	SeatsTrove:Clean()
end

--> Connections
----------------------------------------

--> Knit Start
----------------------------------------

function BedService:KnitStart()
	self.TransitionService = Knit.GetService("TransitionService")
end

return BedService
