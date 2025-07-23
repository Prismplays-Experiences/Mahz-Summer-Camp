--[=[ lunar
	about = "[DESCRIPTION] Starts rojo sync"
]=]

print("Started Rojo server")

local GameManager = require("@LuneModules/GameManager")
GameManager.Serve()