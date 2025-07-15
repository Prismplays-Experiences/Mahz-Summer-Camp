--[=[ lunar
	about = "[DESCRIPTION] Adds given package to the project and then installs it"
]=]

local Sourcemapifier = require("@LuneModules/InstancesManager/Sourcemapifier")
local GameManager = require("@LuneModules/GameManager")
local Config = require("@LuneModules/Config")

GameManager.GenerateSourcemap(Config.PROJECT, Config.SOURCEMAP)
Sourcemapifier:SyncWithObjects()