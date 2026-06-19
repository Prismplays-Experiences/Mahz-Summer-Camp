local types = require("../types")

type LandmarkSlot = types.LandmarkSlot

local LandmarkSlot = {}
LandmarkSlot.__index = LandmarkSlot

function LandmarkSlot.new(cframe: CFrame)
	local self = setmetatable({}, LandmarkSlot)

	self.cframe = cframe
	self.claimed = false

	return self
end

function LandmarkSlot.Occupy(self: LandmarkSlot, instance: Part | Model | nil)
	self.claimed = true
	self.instance = instance
end

function LandmarkSlot.IsFree(self: LandmarkSlot)
	return not self.claimed
end

function LandmarkSlot.Clear(self: LandmarkSlot, destroyInstance: boolean?)
	self.claimed = false

	if destroyInstance and self.instance then
		self.instance:Destroy()
	end

	self.instance = nil
end

return LandmarkSlot
