local pathfs = require("@LunePackages/pathfs")
local Path = pathfs.Path

local config = require("@LuneModules/Config")
local InstancePathUtils = require("@LuneModules/InstancesManager/InstancePathUtils")
local TableUtils = require("@LuneModules/TableUtils")

local OBJECTS_PATH = Path.new(config.OBJECTS_PATH)

export type TreeComponent = {
    Path: pathfs.Path,
    Children: Tree
}

export type Tree = {
    [string]: TreeComponent
}

export type ObjectsTree = {
    _tree: TreeComponent,

    GenerateFromFiles: (self: ObjectsTree) -> (),
    GetTree: (self: ObjectsTree) -> TreeComponent,
    Map: (self: ObjectsTree, callback: (component: TreeComponent, name: string) -> {}, childrenName: string?, childKeyCallback: ((index: number, childName: string, child: TreeComponent) -> any)?) -> {},

    _addComponent: (self: ObjectsTree, path: pathfs.Path) -> ()
}

type Component<K> = {[string] : {K: Component<K>}?} & {[any]: any}

local ObjectsTree = {}
ObjectsTree._tree = {
    Path = OBJECTS_PATH,
    Children = {}
} :: TreeComponent

function ObjectsTree.Map(self: ObjectsTree, callback: (component: TreeComponent, name: string) -> {}, childrenName: string?, childKeyCallback: ((index: number, childName: string, child: TreeComponent) -> any)?): {[any]: any}
    local originalTree = self:GetTree()

    local mappedObjects = TableUtils.NestedMap(originalTree, config.OBJECTS_PATH, "Children", callback, childrenName, childKeyCallback)

    return mappedObjects
end

function ObjectsTree.GenerateFromFiles(self: ObjectsTree)
    for _, serviceName in pairs(InstancePathUtils.GetServicesForSavingArray()) do
        local servicePath: pathfs.Path = OBJECTS_PATH:join(serviceName)
        
        self:_addComponent(servicePath)
    end
end

function ObjectsTree.GetTree(self: ObjectsTree): TreeComponent
    return self._tree
end

function ObjectsTree._addComponent(self: ObjectsTree, path: pathfs.Path)
    local tree = self:GetTree()
    local name = path:fileStem()
    local components = path:components():collect()
    local initPath = path:join("init.rbxm")

    local treeComponent: TreeComponent = {
        Path = if pathfs.findFile(initPath) then initPath else path,
        Children = {}
    }

    local cursor = tree

    for index, component in components do
        if index == 1 or index == #components then
            continue
        end

        local componentName = component:toString()

        cursor.Children[componentName] = cursor.Children[componentName] or {
            Children = {}
        }

        cursor = cursor.Children[componentName]
    end

    cursor.Children[name] = treeComponent

    if pathfs.findFile(path) then
        return
    end

    for _, entry in pathfs.getEntries(path) do
        if entry.name == "init.rbxm" then
            continue
        end

        self:_addComponent(entry.path)
    end
end

return ObjectsTree