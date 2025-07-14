--> Services
----------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

--> Assets
----------------------------------------

local Packages = ReplicatedStorage.Packages
local Events = ReplicatedStorage.Events

--> Modules
----------------------------------------
local Knit = require(Packages.Knit)
local Signal = require(Packages.Signal)

local Modules = ReplicatedStorage:WaitForChild("Modules")
local TeleportModule = Modules:WaitForChild("TeleportModule")
local TeleportZoneService = script.Parent
local SafeTeleport = require(TeleportModule.SafeTeleport)
local Config = require(TeleportModule.Config)
local Zone = require(Packages:WaitForChild("ZonePlus"))

--> Workspace
----------------------------------------
local Workspace = game.Workspace
local ScriptingProperties = Workspace:WaitForChild("Game"):WaitForChild("ScriptingProperties")
local Zones = ScriptingProperties:WaitForChild("Zones")

--> Main Functions
----------------------------------------

local TeleportZoneService = Knit.CreateService({
	Name = "TeleportZoneService",
	Portals = {},
	Client = {
		-- Status = Knit.CreateUnreliableSignal(),
	},
})

function TeleportZoneService:add(x)
	self.Portals[x] = {
		Portal = x,
		Cam = x.Cam,
		hitbox = x,
		holder = x:FindFirstChild("StatusHolder"),
		UI = x:FindFirstChild("StatusHolder"):FindFirstChild("BillboardGui"),
		Zone = Zone.new(x),
		MaxPlayers = x:GetAttribute('MaxPlayers'),

		running_loops = {},
		players = {},
	}

	---// Init

	self:Initialize(x)
end

function TeleportZoneService:PlayerEntered(player: Player, x)
	if #x.players >= x.MaxPlayers then
		return
	end
	if table.find(x.players, player) then
		return
	end

	--warn(("@%s entered the zone!"):format(player.Name))

	table.insert(x.players, player)

	local ZoneData = {
		Cam = x.Cam,
		StatusHolder = x.UI,
	}

	-- self.Client.Status:Fire(player, true, ZoneData)

	self:__UpdateText("Players", ("%d/%d"):format(#x.players, x.MaxPlayers), x)

	if #x.players < x.MaxPlayers then
		-- Events.Exit:FireClient(player, true)
	end
end
function TeleportZoneService:PlayerExited(player: Player, x)
	if not table.find(x.players, player) then
		return
	end

	--warn(("@%s exited the zone!"):format(player.Name))
	-- self.Client.Status:Fire(player, false)
	-- Events.Exit:FireClient(player)
	table.remove(x.players, table.find(x.players, player) or 0)

	self:__UpdateText("Players", ("%d/%d"):format(#x.players, x.MaxPlayers), x)

	if #x.players < Config.MinPlayers then
		x.running_loops = {}
	end
end

function TeleportZoneService:Initialize(x)
	self.Portals[x].Zone.playerEntered:Connect(function(player)
		self:PlayerEntered(player, self.Portals[x])
	end)
	self.Portals[x].Zone.playerExited:Connect(function(player)
		self:PlayerExited(player, self.Portals[x])
	end)

	self:__UpdateText("Players", ("%d/%d"):format(#self.Portals[x].players, self.Portals[x].MaxPlayers), self.Portals[x])
	self:__TeleportLoop(self.Portals[x])
end

function TeleportZoneService:__TeleportLoop(x)
	task.spawn(function()
		while true do
			task.wait()

			if #x.players >= x.MaxPlayers then
				x.running_loops = {}
				self:__Teleport(x)
			elseif #x.players >= Config.MinPlayers then
				if #x.running_loops ~= 0 then
					continue
				end

				local generated_id = HttpService:GenerateGUID()
				table.insert(x.running_loops, generated_id)

				task.spawn(function()
					for i = 10, 1, -1 do
						if not table.find(x.running_loops, generated_id) then
							return
						end
						self:__UpdateText("Teleporting", ("Teleporting in: %d"):format(i), x)

						task.wait(1)
					end
					self:__UpdateText("Teleporting", "Teleporting...", x)
					self:__Teleport(x)
				end)
			else
				self:__UpdateText("Teleporting", "Waiting for players...", x)
			end
		end
	end)
end
function TeleportZoneService:__UpdateText(name, value, x)
	if x.UI then
		if x.UI[name].Text == value then
			return
		end
		x.UI[name].Text = value
	end
end
function TeleportZoneService:__Teleport(x)
	local data = Instance.new("TeleportOptions")

	local ids = {}

	for _, plr in x.players do
		table.insert(ids, plr.UserId)
	end

	data:SetTeleportData({
		Players = ids,
	})

	local success, _ = SafeTeleport(Config.target_id, x.players, data)
	if success then
		--warn('Teleportation successful!')

		task.wait(5)
		x.players = {}
	end
	return success
end

--> Knit Start
----------------------------------------
function TeleportZoneService:KnitStart()
	for i, v in Zones:GetChildren() do
		self:add(v)
	end
end

return TeleportZoneService
