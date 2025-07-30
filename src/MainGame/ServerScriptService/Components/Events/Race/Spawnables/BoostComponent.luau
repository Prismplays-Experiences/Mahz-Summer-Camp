local Component = require("@Packages/Component")
local Knit = require("@Packages/Knit")

export type BoostComponent = {
	Instance: BasePart & {
		["0"]: Attachment,
		["1"]: Attachment,
		Beam: Beam,
	},

	_fixBeam: (self: BoostComponent) -> (),
	_connectEvents: (self: BoostComponent) -> (),
	_getPlayerFromPart: (part: BasePart) -> Player?,
	_speedUpPlayer: (player: Player) -> (),
}

local BoostComponent = Component.new({
	Tag = "Boost",
})

function BoostComponent.Construct(self: BoostComponent)
	self:_fixBeam()
	self:_connectEvents()
end

function BoostComponent._fixBeam(self: BoostComponent)
	self.Instance.Beam.Attachment0 = self.Instance["0"]
	self.Instance.Beam.Attachment1 = self.Instance["1"]
end

function BoostComponent._connectEvents(self: BoostComponent)
	self.Instance.Touched:Connect(function(otherPart)
		local player = self._getPlayerFromPart(otherPart)

		if player then
			self._speedUpPlayer(player)
		end
	end)
end

function BoostComponent._getPlayerFromPart(part: BasePart): Player?
	local character = part.Parent

	if character and character:IsA("Model") and character:FindFirstChild("Humanoid") then
		local player = game.Players:GetPlayerFromCharacter(character)
		return player
	end

	return nil
end

function BoostComponent._speedUpPlayer(player: Player)
	local raceSpeedService = Knit.GetService("RaceSpeedService")

	raceSpeedService:BoostPlayer(player)
end

return BoostComponent
