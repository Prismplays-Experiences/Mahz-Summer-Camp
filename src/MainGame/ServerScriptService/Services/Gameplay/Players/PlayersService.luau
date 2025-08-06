local Players = game:GetService("Players")

local Signal = require("@Packages/Signal")
local Knit = require("@Packages/Knit")

export type PlayersService = {
	PlayerDied: Signal.Signal<Player>,

	_playerFunctions: { (player: Player) -> () },
	_characterFunctions: { (character: Model, player: Player) -> () },

	AddPlayerFunction: (self: PlayersService, func: (player: Player) -> ()) -> (),
	AddCharacterFunction: (self: PlayersService, func: (character: Model, player: Player) -> ()) -> (),
	GetPlayerFunctions: (self: PlayersService) -> { (player: Player) -> () },
	GetCharacterFunctions: (self: PlayersService) -> { (character: Model, player: Player) -> () },

	_setProperties: (self: PlayersService) -> (),
	_createSignals: (self: PlayersService) -> (),
	_connectEvents: (self: PlayersService) -> (),
}

local PlayersService = Knit.CreateService({
	Name = "PlayersService",
	Client = {},
})

function PlayersService.KnitInit(self: PlayersService)
	self:_setProperties()
	self:_createSignals()
	self:_connectEvents()
end

function PlayersService.AddPlayerFunction(self: PlayersService, func: (player: Player) -> ())
	table.insert(self:GetPlayerFunctions(), func)

	for _, player in Players:GetPlayers() do
		task.delay(0, function()
			func(player)
		end)
	end
end

function PlayersService.AddCharacterFunction(self: PlayersService, func: (character: Model, player: Player) -> ())
	table.insert(self:GetCharacterFunctions(), func)

	for _, player in Players:GetPlayers() do
		task.delay(0, function()
			local character = player.Character or player.CharacterAdded:Wait()

			func(character, player)
		end)
	end
end

function PlayersService.GetPlayerFunctions(self: PlayersService)
	return self._playerFunctions
end

function PlayersService.GetCharacterFunctions(self: PlayersService)
	return self._characterFunctions
end

function PlayersService._setProperties(self: PlayersService)
	self._characterFunctions = {}
	self._playerFunctions = {}
end

function PlayersService._createSignals(self: PlayersService)
	self.PlayerDied = Signal.new()
end

function PlayersService._connectEvents(self: PlayersService)
	Players.PlayerAdded:Connect(function(player)
		for _, func in self:GetPlayerFunctions() do
			func(player)
		end
	end)

	self:AddPlayerFunction(function(player)
		player.CharacterAdded:Connect(function(character)
			for _, func in self:GetCharacterFunctions() do
				func(character, player)
			end
		end)
	end)

	self:AddCharacterFunction(function(character, player)
		local connection

		connection = character.Humanoid.Died:Connect(function()
			connection:Disconnect()
			self.PlayerDied:Fire(player)
		end)
	end)
end

return PlayersService
