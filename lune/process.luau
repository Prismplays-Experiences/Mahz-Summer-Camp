--[=[ lunar
	about = "[DESCRIPTION] Compiles code"
]=]

local Terminal = require("@LuneModules/Terminal")
local GameManager = require("@LuneModules/GameManager")
local Config = require("@LuneModules/Config")
local Packages = require("@LuneModules/Packages")

Terminal.execute(`powershell -Command \"Remove-Item -Path .\\out\\src\\MainGame\\ServerScriptService\\* -Recurse -Force\"`)
Terminal.execute(`powershell -Command \"Remove-Item -Path .\\out\\src\\MainGame\\StarterCharacterScripts\\* -Recurse -Force\"`)
Terminal.execute(`powershell -Command \"Remove-Item -Path .\\out\\src\\MainGame\\StarterPlayerScripts\\* -Recurse -Force\"`)

Terminal.execute(`powershell -Command \"Remove-Item -Path .\\out\\src\\Mutuals\\MutualServices\\* -Recurse -Force\"`)
Terminal.execute(`powershell -Command \"Remove-Item -Path .\\out\\src\\Mutuals\\MutualControllers\\* -Recurse -Force\"`)
Terminal.execute(`powershell -Command \"Remove-Item -Path .\\out\\src\\Mutuals\\ReplicatedStorage\\* -Recurse -Force\"`)

GameManager.CopyProjectToOut()
print("Copied project to out directory")

GameManager.GenerateSourcemap(Config.PROJECT, Config.SOURCEMAP)
print("Generated sourcemap to out directory")

Packages.Copy()
print("Copied packages to out directory")

Terminal.execute(`darklua process {Config.SRC_PATH.."/MainGame"} {Config.OUT_PATH.."/"..Config.SRC_PATH.."/MainGame"}`)
Terminal.execute(`darklua process {Config.SRC_PATH.."/Mutuals"} {Config.OUT_PATH.."/"..Config.SRC_PATH.."/Mutuals"}`)
print("Scripts processed")

