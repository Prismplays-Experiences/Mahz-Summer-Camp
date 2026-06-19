--> Modules
----------------------------------------
local Knit = require("@Packages/Knit")

--> References
----------------------------------------
--[[
    SendTransitionAll - Send transition to all players -- Parameters [txt]
    SendTransitionSingle - Send transition to one player -- Paremeters [player,txt]

]]

--> Utility Functions
----------------------------------------

--> Main Functions
----------------------------------------

local TransitionService = Knit.CreateService({
	Name = "TransitionService",
	Client = {
		SendTransition = Knit.CreateSignal(),
		EndTransition = Knit.CreateSignal(),
	},
})

function TransitionService:SendTransitionAll(txt: string)
	self.Client.SendTransition:FireAll(txt)
	return self.Client.EndTransition
end

function TransitionService:SendTransitionSingle(player: Player, txt: string)
	self.Client.SendTransition:Fire(player, txt)

	return self.Client.EndTransition
end

--> Connections
----------------------------------------

--> Knit Start
----------------------------------------

return TransitionService
