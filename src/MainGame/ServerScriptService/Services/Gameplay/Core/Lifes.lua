--> Modules
----------------------------------------
local Signal = require("@Packages/Signal")
local Knit = require("@Packages/Knit")
local GeneralInfo = require("@Info/GeneralInfo")

--> Knit Setup
----------------------------------------
local LifeService = Knit.CreateService({
	Name = "LifeService",
	DayEnded = Signal.new(),
	Client = {
		EliminatePlayer = Knit.CreateSignal(),
	},
})

--> Main Functions
----------------------------------------
function LifeService:Refill(Player)
	Player.leaderstats.Lifes.Value = GeneralInfo.MaxLifes
end

function LifeService:GetEliminated()
	-- return {game.Players:FindFirstChild('1_mahz')}
	local eliminated = {}
	for _, plr in game.Players:GetPlayers() do
		if plr:HasTag("Eliminated") then
			table.insert(eliminated, plr)
		end
	end
	return eliminated
end

function LifeService:EliminatePlayer(plr)
	plr.leaderstats.Loses.Value += 1
	plr:AddTag("Eliminated")
	-- self.StageService:Eliminated(true)
	-- self.Client.EliminatePlayer:Fire(plr)
end

function LifeService.Client:LifeRefillEvent(Player)
	local StoredLifes = Player.PrivateStats.Lifes
	if StoredLifes.Value > 0 then
		StoredLifes.Value -= 1
		task.spawn(function()
			self.Server:Refill(Player)
		end)
		return true
	else
		return false
	end
end

function LifeService:RevivePlayer(Player, Strength)
	Player.leaderstats.Loses.Value -= 1
	Player.leaderstats.Lifes.Value = GeneralInfo.MaxLifes
	Player:RemoveTag("Eliminated")
	-- local Day = self.ClockService:GetDay()
	Player.leaderstats.Strength.Value = GeneralInfo.Strength - (self.TargetService.TotalStrengthLost or 1)
	if Strength and tonumber(Strength) then
		Player.leaderstats.Strength.Value = math.clamp(
			Player.leaderstats.Strength.Value - tonumber(Strength),
			GeneralInfo.EndStrength,
			GeneralInfo.Strength
		)
	end
	print("Strength after revive: " .. Player.leaderstats.Strength.Value)
	-- pcall(function()
	Player.Character:MoveTo(workspace.Game.SpawnLocations.SpawnLocation.Position + Vector3.new(0, 5, 0))
	-- end)
end

function LifeService:KnitStart()
	-- self.StageService = Knit.GetService("StageService")
	self.ClockService = Knit.GetService("ClockService")
	self.TargetService = Knit.GetService("TargetService")

	local function PlayerAdded(Player)
		local Lifes = Player:WaitForChild("leaderstats"):WaitForChild("Lifes")
		Lifes:GetPropertyChangedSignal("Value"):Connect(function()
			if Lifes.Value <= 0 and not Player:HasTag("Eliminated") then
				self:EliminatePlayer(Player)
				self.ClockService:YieldClock()
				-- self.StageService:Eliminated(true, true)
				self.ClockService:ResumeClock()
			end
		end)
	end

	game.Players.PlayerAdded:Connect(PlayerAdded)
	for _, Player in pairs(game.Players:GetPlayers()) do
		PlayerAdded(Player)
	end
end

return LifeService
