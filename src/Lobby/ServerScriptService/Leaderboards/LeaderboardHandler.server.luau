repeat
	task.wait()
until game.Workspace.PersistentLoaded

local ScriptingProperties = workspace:WaitForChild("Game"):WaitForChild("ScriptingProperties")

local Leaderboards = ScriptingProperties.Leaderboards

local RunningLb = {}

for i, v in pairs(Leaderboards:GetChildren()) do
	if string.find(v.Name, "LB") then
		RunningLb[tostring(v.Name:gsub("LB", "")) .. i] = { v, tostring(v.Name:gsub("LB", "")) }
	end
end

local LeaderboardContentsModule = script.Parent:WaitForChild("LeaderboardContents")
local LeaderboardContents = require(LeaderboardContentsModule)

for _, v in pairs(RunningLb) do
	local success, error_message = pcall(function()
		task.spawn(function()
			--repeat task.wait() until v[1]:FindFirstChild('Holder')
			LeaderboardContents.Embed(v[1]:WaitForChild("Holder"), v[2], false)
		end)
	end)
	if not success then
		warn("Error embedding leaderboard:", error_message)
	end
end
