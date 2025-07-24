--[=[ lunar
	about = "[DESCRIPTION] Unlocks game from maintenance. This will allow players to join the game again"
]=]

local GameManager = require("@LuneModules/GameManager")

GameManager:Unlock("Mutuals")

print("Game is now unlocked. Players can join again.")
