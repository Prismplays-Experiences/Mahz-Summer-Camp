local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local DataModules = script.Parent

local ProfileService = require(DataModules:WaitForChild('ProfileService'))
local Template = require(script.Parent:WaitForChild('Template'))
local PlayerInitials = require(script.Parent:WaitForChild('PlayerInitials'))

local dataKey = if RunService:IsStudio() then "TestData12" else "_Dataset5"
-- Used_data_sets = : _Dataset7,_Dataset1,_Dataset2,_Dataset3
local profileStore = ProfileService.GetProfileStore(dataKey,Template)

local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local DataManager = Knit.CreateService {
	Name = "DataManager",
	Client = {}
}
DataManager.Profiles = {}




function DataManager:GetProfile(player: Player)
	return self.Profiles[player]
end

local function PlayerAdded(player: Player)
	
	local Profile = profileStore:LoadProfileAsync("Player_"..player.UserId)
	if Profile~= nil then
		
		Profile:AddUserId(player.UserId)
		Profile:Reconcile()
		
		Profile:ListenToRelease(function()
			DataManager.Profiles[player] = nil
			player:Kick('Theres been an error, rejoin')	
		end)
		
		if player:IsDescendantOf(Players) then
			
			DataManager.Profiles[player] = Profile
			PlayerInitials:Create(player,Profile)
			
		else
			Profile:Release()
			
		end
	else
		player:Kick('There has been an error, rejoin')
		
	end

end

local function PlayerRemoving(player: Player)
	local profile = DataManager.Profiles[player]
	
	if profile~= nil then
		profile:Release()
	end
	
end

for _,player in Players:GetPlayers() do
	
	task.spawn(PlayerAdded,player)
	
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)



return DataManager