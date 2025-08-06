local BookedInstance = require(script.BookedInstance)
local TableUtil = require("@Packages/TableUtil")

export type Booker<T> = {
	_template: T,
	_bookedInstances: {},

	new: (template: T) -> Booker<T>,

	Book: (self: Booker<T>, quantity: number?, cloningTimeInterval: number?, await: boolean?) -> (),
	GetTemplate: (self: Booker<T>) -> T,

	Clone: (self: Booker<T>) -> BookedInstance.BookedInstance<T>,

	GetFreeInstances: (self: Booker<T>) -> { BookedInstance.BookedInstance<T> },
	GetBookedInstances: (self: Booker<T>) -> { BookedInstance.BookedInstance<T> },
}

local DEFAULT_CLONING_TIME_INTERVAL = 0

local Booker = {}
Booker.__index = Booker

function Booker.new<T>(template: T): Booker<T>
	local self = setmetatable({}, Booker)

	self._template = template
	self._bookedInstances = {}

	return self
end

function Booker.Book<T>(self: Booker<T>, quantity: number?, cloningTimeInterval: number?, await: boolean?)
	cloningTimeInterval = cloningTimeInterval or DEFAULT_CLONING_TIME_INTERVAL
	await = await or false
	quantity = quantity or 1

	local function book()
		for _ = 1, quantity :: number do
			local template = self:GetTemplate()
			local instance = template:Clone()
			local bookedInstance = BookedInstance.new(instance)

			table.insert(self:GetBookedInstances(), bookedInstance)
			task.wait(cloningTimeInterval)
		end
	end

	if await then
		book()
	else
		task.spawn(function()
			book()
		end)
	end
end

function Booker.Clone<T>(self: Booker<T>): BookedInstance.BookedInstance<T>?
	local freeInstances = self:GetFreeInstances()

	if #freeInstances == 0 then
		warn(
			"No free instances available to clone, make sure to use :Book(). Script will book a one instead automatically"
		)

		self:Book(1, DEFAULT_CLONING_TIME_INTERVAL, true)

		return self:Clone()
	end

	local randomBookedInstance = TableUtil.Sample(freeInstances, 1)[1]

	return randomBookedInstance
end

function Booker.GetFreeInstances<T>(self: Booker<T>): { BookedInstance.BookedInstance<T> }
	local bookedInstances = self:GetBookedInstances()

	local freeInstances = TableUtil.Filter(bookedInstances, function(instance)
		return not instance:IsActive()
	end)

	return freeInstances
end

function Booker.GetBookedInstances<T>(self: Booker<T>): { BookedInstance.BookedInstance<T> }
	return self._bookedInstances
end

function Booker.GetTemplate<T>(self: Booker<T>): T
	return self._template
end

return Booker
