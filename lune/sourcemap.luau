--[=[ lunar
	about = "[DESCRIPTION] Generates a sourcemap for the project. This updates roblox-ui explorer and intellisense"
]=]

local Sourcemapifier = require("@LuneModules/InstancesManager/Sourcemapifier")
local GameManager = require("@LuneModules/GameManager")
local Config = require("@LuneModules/Config")

GameManager.GenerateSourcemap(Config:GetProjectPath(), Config.GetSourcemapPath())
Sourcemapifier:SyncWithObjects()

print("Sourcemap generated and synced with objects")
