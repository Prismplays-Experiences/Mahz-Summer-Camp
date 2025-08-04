local Players = game:GetService("Players")

local RaceInfo = require("@Info/Events/RaceInfo")
local Fusion = require("@Packages/Fusion")
local Knit = require("@Packages/Knit")
local types = require("../../../types")

type PowerupsFillerController = types.PowerupsFillerController

local player = Players.LocalPlayer

local FILLER = RaceInfo.ui.powerupFiller(player)
local COOLDOWN = RaceInfo.powerupsOverallInfo.cooldown

local SPRING_SPEED = RaceInfo.ui.cooldownSpringSpeed
local SPRING_DAMPING = RaceInfo.ui.cooldownSpringDamping

local PowerupsFillerController = Knit.CreateController({
	Name = "PowerupsFillerController",
})

function PowerupsFillerController.KnitInit(self: PowerupsFillerController)
	self:_setProperties()
	self:_hydrateFiller()
end

function PowerupsFillerController.SetLastTimeUsed(self: PowerupsFillerController, lastTimeUsed: number)
	local lastTimeUsedValue = self:_getLastTimeUsed()

	lastTimeUsedValue:set(lastTimeUsed)
end

function PowerupsFillerController._setProperties(self: PowerupsFillerController)
	self._filler = FILLER
	self._scope = Fusion.scoped({
		Value = Fusion.Value,
		Computed = Fusion.Computed,
		Hydrate = Fusion.Hydrate,
		Spring = Fusion.Spring,
	})
	self._lastTimeUsed = self._scope:Value(0)
end

function PowerupsFillerController._hydrateFiller(self: PowerupsFillerController)
	local scope = self:_getScope()
	local filler = self:_getFiller()
	local gradient = filler.UIGradient
	local lastTimeUsed = self:_getLastTimeUsed()
	local currentTime = scope:Value(os.time())

	task.spawn(function()
		while wait(1) do
			currentTime:set(os.time())
		end
	end)

	local computedAlpha = scope:Computed(function(use)
		local timeDiff = use(currentTime) - use(lastTimeUsed)
		local alpha = math.clamp(1 - timeDiff / COOLDOWN, 0, 1)

		return alpha
	end)

	local alphaSpring = scope:Spring(computedAlpha, SPRING_SPEED, SPRING_DAMPING)

	local gradientTransparency = scope:Computed(function(use)
		local alpha = use(alphaSpring)
		local sequence = {}

		sequence = {
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(math.clamp(alpha + 0.001, 0.001, 0.998), 0),
			NumberSequenceKeypoint.new(math.min(0.999, alpha + 0.002), 1),
			NumberSequenceKeypoint.new(1, 1),
		}

		return NumberSequence.new(sequence)
	end)

	scope:Hydrate(gradient)({
		Transparency = gradientTransparency,
	})
end

function PowerupsFillerController._getFiller(self: PowerupsFillerController)
	return self._filler
end

function PowerupsFillerController._getScope(self: PowerupsFillerController)
	return self._scope
end

function PowerupsFillerController._getLastTimeUsed(self: PowerupsFillerController)
	return self._lastTimeUsed
end

return PowerupsFillerController
