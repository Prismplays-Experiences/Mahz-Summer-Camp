local Terminal = require("@LuneModules/Terminal")

local DeployManager = {}

function DeployManager.Deploy(path: string, environment: string)
	Terminal.execute(`mantle deploy {path} --environment {environment}`)
end

return DeployManager
