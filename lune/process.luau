--[=[ lunar
	about = "[DESCRIPTION] Compiles code"
]=]

local Terminal = require("@LuneModules/Terminal")
local GameManager = require("@LuneModules/GameManager")
local Config = require("@LuneModules/Config")

Terminal.execute(`powershell -Command \"Remove-Item -Path .\\out\\src\\server\\* -Recurse -Force\"`)
Terminal.execute(`powershell -Command \"Remove-Item -Path .\\out\\src\\client\\* -Recurse -Force\"`)
Terminal.execute(`powershell -Command \"Remove-Item -Path .\\out\\src\\shared\\* -Recurse -Force\"`)

GameManager.CopyProjectToOut()
print("Copied project to out directory")

GameManager.GenerateSourcemap(Config.PROJECT, Config.SOURCEMAP)
print("Generated sourcemap to out directory")

Terminal.execute(`darklua process {Config.SRC_PATH} {Config.OUT_PATH.."/"..Config.SRC_PATH}`)
print("Scripts processed")

