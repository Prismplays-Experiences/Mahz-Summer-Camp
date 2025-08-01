export type BookedInstance<T> = T & {
	_instance: T,
	_active: boolean,

	Activate: (self: BookedInstance<T>) -> (),
	Destroy: (self: BookedInstance<T>) -> (),
	IsActive: (self: BookedInstance<T>) -> boolean,
	GetRawInstance: (self: BookedInstance<T>) -> T,

	_setPosition: (self: BookedInstance<T>, position: Vector3) -> (),
}

local DESTROY_POSITION = Vector3.one * 512
local BOOKED_INSTANCES_FOLDER = workspace:FindFirstChild("__BOOKED_INSTANCES__") or Instance.new("Folder")
BOOKED_INSTANCES_FOLDER.Name = "__BOOKED_INSTANCES__"
BOOKED_INSTANCES_FOLDER.Parent = workspace

local BookedInstance = {}

function BookedInstance.new<T>(instance: T & {[any]: any}): BookedInstance<T>
	local info = {}

	local self = newproxy(true)
	local proxyMetaTable = getmetatable(self)

	proxyMetaTable.__index = function(_, key)
		local value

		if key == "_active" or key == "_instance" or BookedInstance[key] ~= nil then
			value = info[key] or BookedInstance[key]
		else
			value = (instance :: {[any]: any})[key]

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
			(instance :: {[any]: any})[key] = value
		end
	end

	self._instance = instance
	self:Destroy()

	return self
end

function BookedInstance.Activate<T>(self: BookedInstance<T>)
	if self:IsActive() then
		return
	end

	self._active = true
end

function BookedInstance.Destroy<T>(self: BookedInstance<T>)
	if self:IsActive() == false then
		return
	end

	self:_setPosition(DESTROY_POSITION)
	self._active = false

	(self :: {[any]: any}).Parent = BOOKED_INSTANCES_FOLDER
end

function BookedInstance.IsActive<T>(self: BookedInstance<T>): boolean
	return self._active
end

function BookedInstance._setPosition<T>(self: BookedInstance<T>, position: Vector3)
	local instance = self:GetRawInstance()

	if instance.PivotTo ~= nil then
		instance:PivotTo(CFrame.new(position))
	elseif instance.Position ~= nil then
		(instance :: Part).Position = position
	end
end

function BookedInstance.GetRawInstance<T>(self: BookedInstance<T>): T
	return self._instance
end

return BookedInstance
