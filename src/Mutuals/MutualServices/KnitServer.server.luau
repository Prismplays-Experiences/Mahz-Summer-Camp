local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local packages = ReplicatedStorage.Packages
local Knit = require(packages.Knit)

local services = ServerScriptService
-- local components = ServerScriptService.Components

-- for _, component in components:GetDescendants() do
-- 	if not component.Name:match("Component") then
-- 		continue
-- 	end

-- 	require(component)
-- end

Knit.AddServicesDeep(services)
Knit.Start():catch(warn)
