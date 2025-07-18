local Terminal = require("@LuneModules/Terminal")

local AssetsModule = {}

function AssetsModule.Sync()
    print("Syncing assets...")
    
    Terminal.execute("asphalt sync")
end

return AssetsModule
