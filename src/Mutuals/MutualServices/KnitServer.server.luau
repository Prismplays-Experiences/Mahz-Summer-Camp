local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require("@Packages/Knit")

local services = ServerScriptService

Knit.AddServicesDeep(services)
Knit.Start():catch(warn)
