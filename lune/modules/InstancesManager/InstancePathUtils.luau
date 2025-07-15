local roblox = require("@lune/roblox")

local SERVICES_FOR_SAVING_ARRAY = {
	"StarterGui",
	"Workspace",
	"ReplicatedStorage",
	"Lighting",
	"ServerStorage",
}

local BANNED_SYMBOLS = {
	["\\"] = true,
	["/"] = true,
	[":"] = true,
	["*"] = true,
	["?"] = true,
	['"'] = true,
	["<"] = true,
	[">"] = true,
	["|"] = true,
}

local REPLICATED_STORAGE_EXCLUDED = { "Assets", "CustomModules", "Events", "Info", "Packages", "Marketing", "GameStatus", "Shared" }

local module = {}

function module.FixName(name: string)
	local result = {}

	for characterIndex = 1, #name do
		local character = name:sub(characterIndex, characterIndex)
		
		if not BANNED_SYMBOLS[character] then
			table.insert(result, character)
		end
	end

	return table.concat(result)
end

function module.GetInstanceByPath(path: string, game: DataModel)
	local instances: { Instance } = {}
	local instancesNames: { string } = string.split(path, "/")
	table.remove(instancesNames, 1)

	for index, instanceName: string in instancesNames do
		local serviceInstance = module.GetServiceByPath(instanceName, game)

		if serviceInstance then
			table.insert(instances, serviceInstance)
			continue
		end

		local previousFolder = instances[index - 1]
		local currentFolder = previousFolder:FindFirstChild(instanceName) or roblox.Instance.new("Folder")

		currentFolder.Parent = previousFolder
		currentFolder.Name = instanceName

		table.insert(instances, currentFolder)
	end

	return instances[#instances]
end

function module.GetServiceByPath(path: string, game: DataModel)
	local serviceInstance = module.GetServicesPathsDictionary(game)[path]

	return serviceInstance
end

function module.GetServicesPathsDictionary(game: DataModel)
	local servicesPathsDictionary = {}

	for _, serviceName: string in pairs(SERVICES_FOR_SAVING_ARRAY) do
		servicesPathsDictionary[serviceName] = game:GetService(serviceName)
	end

	return servicesPathsDictionary
end

function module.GetServicesForSavingArray()
	return SERVICES_FOR_SAVING_ARRAY
end

function module.GetReplicatedExcludedArray()
	return REPLICATED_STORAGE_EXCLUDED
end

return module
