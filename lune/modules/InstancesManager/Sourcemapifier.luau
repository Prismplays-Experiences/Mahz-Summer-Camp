local pathfs = require("@LunePackages/PathFS")

local fs = pathfs.fs
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")

local InstancePathUtils = require("@LuneModules/InstancesManager/InstancePathUtils")
local ObjectsTree = require("@LuneModules/InstancesManager/ObjectsTree")
local TableUtils = require("@LuneModules/TableUtils")

local SERVICES_FOR_SAVING_ARRAY = InstancePathUtils.GetServicesForSavingArray()

export type Sourcemapifier = {
	SyncWithObjects: (self: Sourcemapifier) -> (),

	_getTree: () -> { [any]: any },
}

local Sourcemapifier = {}

function Sourcemapifier.SyncWithObjects(self: Sourcemapifier)
	local objectsTree = self._getTree()

	local sourcemapJson = fs.readFile("sourcemap.json")

	local currentTree: { [any]: any } = serde.decode("json", sourcemapJson)
	local currentDataTree = currentTree.children

	local newTree = table.clone(currentTree)

	for indexInObjects, componentInObjects in pairs(objectsTree) do
		if table.find(SERVICES_FOR_SAVING_ARRAY, componentInObjects.name) then
			local alreadyExists = false

			for _, componentInCurrent in pairs(currentDataTree) do
				if componentInCurrent.name == componentInObjects.name then
					alreadyExists = true

					break
				end
			end

			if alreadyExists and componentInObjects.name ~= "ReplicatedStorage" then
				continue
			end
		end

		if componentInObjects.name == "ReplicatedStorage" then
			for _, componentInCurrent in pairs(currentDataTree) do
				if componentInCurrent.name == "ReplicatedStorage" then
					local _, trueIndex = TableUtils.Find(newTree.children, function(child)
						return child.name == "ReplicatedStorage"
					end)

					local newComponent = {
						name = componentInObjects.name,
						className = "ReplicatedStorage",
						children = TableUtils.Extend(componentInCurrent.children, componentInObjects.children),
					}

					newTree.children[trueIndex] = newComponent

					break
				end
			end

			continue
		end

		table.insert(newTree.children, objectsTree[indexInObjects])
	end

	table.remove(newTree.children, table.find(newTree.children, "Folder"))

	for index, componentInCurrent in pairs(newTree.children) do
		if componentInCurrent._inner then
			table.remove(newTree.children, index)
		end
	end

	local encodedTree = serde.encode("json", newTree, true)

	encodedTree = encodedTree:gsub("{}", "[]")

	fs.writeFile("sourcemap.json", encodedTree)
end

function Sourcemapifier._getTree()
	ObjectsTree:GenerateFromFiles()

	local newTree = ObjectsTree:Map(function(component: ObjectsTree.TreeComponent, name: string): {}
		local path = component.Path

		if pathfs.findDir(path) then
			local className = if table.find(SERVICES_FOR_SAVING_ARRAY, name) then name else "Folder"

			return {
				name = name,
				className = className,
			}
		end

		local content = fs.readFile(path:toString())
		local instance = roblox.deserializeModel(content)[1]

		return {
			name = name,
			className = instance.ClassName,
		}
	end).children

	return newTree
end

return Sourcemapifier
