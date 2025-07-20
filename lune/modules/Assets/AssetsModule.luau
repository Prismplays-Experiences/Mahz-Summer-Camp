local Terminal = require("@LuneModules/Terminal")
local Compiler = require("@LuneModules/Compiler")

local AssetsModule = {}

function AssetsModule.Sync()
	local path = "src/Mutuals/ReplicatedStorage/assets.luau"

	print("Syncing assets...")

	Terminal.execute("asphalt sync")
	Terminal.execute(`stylua {path}`)

	Compiler.CompileFile(path)
end

return AssetsModule
