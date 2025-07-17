local Terminal = require("@LuneModules/Terminal")

local MantleConfig = require("@LuneModules/MantleConfig")

local DeployManager = {}

function DeployManager.Deploy(tag: string?)
	local path, environment = MantleConfig.GetWorkingConfig(tag)

	Terminal.execute(`mantle deploy {path} --environment {environment}`)
end

return DeployManager
