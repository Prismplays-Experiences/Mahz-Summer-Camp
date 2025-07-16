local Compiler = require("@LuneModules/Compiler")
local Config = require("@LuneModules/Config")

Compiler:Compile(Config.PROJECT)
print("Compiled project successfully")