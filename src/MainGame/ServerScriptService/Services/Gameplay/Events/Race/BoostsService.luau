local Knit = require("@Packages/Knit")
local RaceInfo = require("@Info/Events/Race")
local types = require("./types")

local BOOSTS_COUNT = RaceInfo.boosts.count

type BoostsService = types.BoostsService

local BoostsService = Knit.CreateService({
	Name = "BoostsService",
	Client = {
		BoostSpawned = Knit.CreateSignal("BoostSpawned"),
	},
})

function BoostsService.KnitInit()
	-- Initialization logic can go here if needed
end

function BoostsService.SpawnAll(self: BoostsService)
	for _ = 1, BOOSTS_COUNT do
		self._spawnOne()
	end
end

function BoostsService._spawnOne()
	-- Logic to spawn a single boost
	-- This could involve creating an instance, setting properties, and firing the BoostSpawned signal
	local boost = Instance.new("Part") -- Example, replace with actual boost logic
	boost.Name = "Boost"
	boost.Size = Vector3.new(1, 1, 1)
	boost.Position = Vector3.new(math.random(-50, 50), 10, math.random(-50, 50)) -- Random position
	boost.Parent = workspace -- Adjust parent as needed

	BoostsService.Client.BoostSpawned:Fire(boost)
end

return BoostsService