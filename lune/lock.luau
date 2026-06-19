--[=[ lunar
	about = "[DESCRIPTION] Locks game for maintenance. This will prevent players from joining the game until it is unlocked again"
]=]

local GameManager = require("@LuneModules/GameManager")

GameManager:Lock("Mutuals")

print("Game is now locked. Players will be kicked if they try to join.")
