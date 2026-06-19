local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cache = {}
local Npc = {}
local AutomaticNpc = {}

local IS_CLIENT = RunService:IsClient()
local IS_SERVER = RunService:IsServer()

local ClientReplicate
local ServerReplicate
if IS_CLIENT then
	ClientReplicate = require(script.Parent.Parent.client.replicate)
else
	ServerReplicate = require(script.Parent.Parent.server.replicate)
end

local CAMERA = Instance.new("Camera", workspace)
CAMERA.Name = "NPCCacheCamera"
local NPC_MODEL_CACHE
if IS_SERVER then
	NPC_MODEL_CACHE = Instance.new("Folder", ReplicatedStorage)
	NPC_MODEL_CACHE.Name = "NPC_MODEL_CACHE"
elseif IS_CLIENT then
	NPC_MODEL_CACHE = ReplicatedStorage:WaitForChild("NPC_MODEL_CACHE") :: any
end

local function ClientRegister(model: Model)
	local id = tonumber(model:GetAttribute("NPC_ID"))
	local npcType = tostring(model:GetAttribute("NPC_TYPE") or "DEFAULT")
	if not id then
		warn("NPC model does not have an NPC_ID attribute:", model:GetFullName())
		return
	end

	local clone = model:Clone()
	clone.Name = tostring(id)
	clone.Parent = CAMERA;
	(clone.PrimaryPart :: any).Anchored = true
	Cache[id] = clone 
	ClientReplicate.RegisterClientNPC(id, clone, npcType)

	model.AncestryChanged:Connect(function()
		if not model.Parent then
			ClientReplicate.UnregisterNPC(id)
			Cache[id] = nil
			clone:Destroy()
		end
	end)
end

local function Check()
	for i, npc in NPC_MODEL_CACHE:GetChildren() do
		if not npc:IsA("Model") then
			continue
		end
		ClientRegister(npc)
	end
end

function Npc.Register(model: Model, npcType: string?, folderName: string?, automaticUpdate: boolean?)
	if IS_CLIENT then
		error("Register can only be called on the server.")
	end
	if not model then
		error("Npc cache requires a model to register.")
	end

	local folder_: string = folderName or "DEFAULT"
	local folder: Folder = (CAMERA:FindFirstChild(folder_) or Instance.new("Folder", CAMERA)) :: any
	folder.Name = folder_

	local id = ServerReplicate.RegisterNPC(model, npcType)
	Cache[id] = model
	model.Parent = folder

	pcall(function()
		(model.PrimaryPart :: any):SetNetworkOwner(nil)
	end)

	local clone = model:Clone() --// MAKE SURE Archivable is set to true
	clone.Name = tostring(id)
	clone.Parent = NPC_MODEL_CACHE --//This can be optimized in the future

	if automaticUpdate then
		AutomaticNpc[id] = model
	end
end

function Npc.UnRegister(idOrModel: number | Model): Model
	if IS_CLIENT then
		error("UnRegister can only be called on the server.")
	end
	local id = type(idOrModel) == "number" and idOrModel or tonumber((idOrModel :: any):GetAttribute("NPC_ID"))
	if not id then
		error("Npc cache requires a valid NPC_ID to unregister.")
	end

	Cache[id] = nil
	AutomaticNpc[id] = nil
	local actualModel = ServerReplicate.UnregisterNPC(id)

	local model = NPC_MODEL_CACHE:FindFirstChild(tostring(id))
	if model then
		model:Destroy()
	end
	if not actualModel then
		error("Npc cache: Unregister failed to find model for ID: " .. id .. " Please Investigate.")
	end
	return actualModel
end

function Npc.GetModel(id: number): Model
	return Cache[id]
end

if IS_CLIENT then
	NPC_MODEL_CACHE.ChildAdded:Connect(function(model)
		if model:IsA("Model") then
			task.defer(ClientRegister, model)
		else
			error("Npc cache: Child added is not a model (WHY, DO NOT TOUCH): " .. model:GetFullName())
		end
	end)
	Check()
else
	RunService.PostSimulation:Connect(function(dt)
		local now = os.clock()
		debug.profilebegin("Check Npc CFrames")
		for id, model in AutomaticNpc do
			if not model.PrimaryPart then
				continue
			end
			local cf = model.PrimaryPart.CFrame
			ServerReplicate.PushNPCTransform(id, cf, now)
		end
		debug.profileend()
	end)
end

return Npc
