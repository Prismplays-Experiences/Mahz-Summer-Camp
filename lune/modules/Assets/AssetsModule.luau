local Terminal = require("@LuneModules/Terminal")

local AssetsModule = {}

function AssetsModule.Sync()
	print("Syncing assets...")

	Terminal.execute("asphalt sync")
	Terminal.execute("stylua src/Mutuals/ReplicatedStorage/assets.luau")
end

return AssetsModule
