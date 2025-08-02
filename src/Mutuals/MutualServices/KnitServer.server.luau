local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require("@Packages/Knit")

local services = ServerScriptService

-- -- THIS IS FOR TESTING WHICH SERVICE RETURNS NIL
-- for _, module in ipairs(services:GetDescendants()) do
-- 	if not module:IsA("ModuleScript") then
-- 		continue
-- 	end

-- 	local success, result = pcall(require, module)
-- 	if not success then
-- 		warn(`Failed to require {module:GetFullName()}: {result}`)
-- 	elseif result == nil then
-- 		warn(`Module {module:GetFullName()} returned nil`)
-- 	end
-- end

Knit.AddServicesDeep(services)
Knit.Start():catch(warn)
