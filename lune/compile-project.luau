--[=[ lunar
	about = "[DESCRIPTION] Copies the project file into out directory"
]=]

local Compiler = require("@LuneModules/Compiler")
local Config = require("@LuneModules/Config")

Compiler:Compile(Config.PROJECT)
print("Compiled project successfully")