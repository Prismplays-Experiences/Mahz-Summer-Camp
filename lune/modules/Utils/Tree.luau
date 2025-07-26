local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.Packages
local TableUtil = require(packages.TableUtil)

export type Tree<T, V> = {
	adjacencyList: { [T]: { [T]: V } },

	addVertex: (self: Tree<T, V>, vertex: T) -> (),
	addEdge: (self: Tree<T, V>, vertex1: T, vertex2: T, weight: V) -> (),
	printGraph: (self: Tree<T, V>) -> (),
	getEdges: (self: Tree<T, V>, vertex1: T) -> { [T]: V },
}

local Tree = {}
Tree.__index = Tree

function Tree.new()
	local self = setmetatable({}, Tree)

	self.adjacencyList = {}

	return self
end

function Tree.addVertex<T, V>(self: Tree<T, V>, vertex: T)
	if not self.adjacencyList[vertex] then
		self.adjacencyList[vertex] = {}
	end
end

function Tree.addEdge<T, V>(self: Tree<T, V>, startVertex: T, envDertex: T)
	if not self.adjacencyList[vertex1] then
		self:addVertex(vertex1)
	end
	if not self.adjacencyList[vertex2] then
		self:addVertex(vertex2)
	end

	self.adjacencyList[vertex1][vertex2] = weight

	if vertex1 ~= vertex2 then
		self.adjacencyList[vertex2][vertex1] = weight
	end
end

function Tree.printGraph<T, V>(self: Tree<T, V>)
	for vertex1, edges in pairs(self.adjacencyList) do
		local edgeStrings = {}
		for vertex2, weight in pairs(edges) do
			table.insert(edgeStrings, string.format("%s(%d)", vertex2, weight))
		end
		print(vertex1 .. ": " .. table.concat(edgeStrings, ", "))
	end
end

function Tree.getEdges<T, V>(self: Tree<T, V>, vertex1: T): { [T]: V }
	return self.adjacencyList[vertex1]
end

return Tree