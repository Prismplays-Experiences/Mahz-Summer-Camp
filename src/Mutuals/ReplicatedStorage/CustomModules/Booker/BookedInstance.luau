export type BookedInstance = Instance & {
	_instance: Instance,
	_active: boolean,

	Activate: (self: BookedInstance) -> (),
	Destroy: (self: BookedInstance) -> (),
	IsActive: (self: BookedInstance) -> boolean,
	GetRawInstance: (self: BookedInstance) -> Instance,

	_setPosition: (self: BookedInstance, position: Vector3) -> (),
}

local DESTROY_POSITION = Vector3.one * 512
local BOOKED_INSTANCES_FOLDER = workspace:FindFirstChild("__BOOKED_INSTANCES__") or Instance.new("Folder")
BOOKED_INSTANCES_FOLDER.Name = "__BOOKED_INSTANCES__"
BOOKED_INSTANCES_FOLDER.Parent = workspace

local BookedInstance = {}
BookedInstance._active = false

function BookedInstance.new(instance: Instance): BookedInstance
	local info = {}

	local self = newproxy(true)
	local proxyMetaTable = getmetatable(self)

	proxyMetaTable.__index = function(_, key)
		local value

		if key == "_active" or key == "_instance" or BookedInstance[key] ~= nil then
			value = BookedInstance[key]
		else
			value = instance[key]

			if typeof(value) == "function" then
				return function(_, ...)
					return value(instance, ...)
				end
			end
		end

		return value
	end

	proxyMetaTable.__newindex = function(_, key, value)
		if key == "_active" or key == "_instance" then
			rawset(info, key, value)
		else
			instance[key] = value
		end
	end

	self._instance = instance
	self:Destroy()

	return self
end

function BookedInstance.Activate(self: BookedInstance)
	if self:IsActive() then
		return
	end

	self._active = true
end

function BookedInstance.Destroy(self: BookedInstance)
	if self:IsActive() == false then
		return
	end

	local instance = self:GetRawInstance()

	self:_setPosition(DESTROY_POSITION)
	self._active = false
	instance.Parent = BOOKED_INSTANCES_FOLDER
end

function BookedInstance.IsActive(self: BookedInstance): boolean
	return self._active
end

function BookedInstance._setPosition(self: BookedInstance, position: Vector3)
	local instance = self:GetRawInstance()

	if typeof(instance) == "Model" then
		instance:PivotTo(CFrame.new(position))
	elseif typeof(instance) == "BasePart" then
		instance.Position = position
	end
end

function BookedInstance.GetRawInstance(self: BookedInstance): Instance
	return self._instance
end

return BookedInstance
