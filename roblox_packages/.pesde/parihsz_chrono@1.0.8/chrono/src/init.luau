local RunService = game:GetService("RunService")

local NpcCache = require(script.shared.npcCache)
local ServerReplicate
local ClientReplicate
local InterpolationBuffer
local RenderCache
local TogglePlayerReplication

if RunService:IsServer() then
	ServerReplicate = require(script.server.replicate)
	TogglePlayerReplication = ServerReplicate.TogglePlayerReplication
else
	ClientReplicate = require(script.client.replicate)
	InterpolationBuffer = require(script.client.interpolationBuffer)
	RenderCache = require(script.client.renderCache)
end

local function LoadFolder(folder: Folder)
	for _, moduleScript in folder:GetDescendants() do
		if moduleScript:IsA("ModuleScript") then
			local yielded = true
			local success, message

			task.spawn(function()
				success, message = pcall(require, moduleScript)

				yielded = false
			end)

			if not success then
				error(`{moduleScript:GetFullName()}: {message}`)
			end

			if yielded then
				warn("Yielded while requiring" .. moduleScript:GetFullName())
			end
		end
	end
end

local Chrono = {}

function Chrono.Start()
	LoadFolder(if RunService:IsServer() then script.server else script.client)
	LoadFolder(script.shared)
end

Chrono.ChronoClient = ClientReplicate
Chrono.ChronoServer = ServerReplicate
Chrono.NpcRegistry = NpcCache
Chrono.Snapshots = require(script.shared.snapshots)
Chrono.InterpolationBuffer = InterpolationBuffer
Chrono.RenderCache = RenderCache
Chrono.TogglePlayerReplication = TogglePlayerReplication

return Chrono
