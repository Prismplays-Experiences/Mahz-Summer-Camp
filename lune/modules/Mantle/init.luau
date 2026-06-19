local DeployManager = require("@LuneModules/Mantle/DeployManager")
local MantleConfig = require("@LuneModules/Mantle/MantleConfig")
local Marketing = require("@LuneModules/Mantle/Marketing")
local ExperienceInfo = require("@LuneModules/Mantle/ExperienceInfo")

local Mantle = {}

export type Info = ExperienceInfo.Info

function Mantle.Deploy(tag: string?)
	local path, environment = MantleConfig.GetWorkingConfig(tag)

	DeployManager.Deploy(path, environment)
end

function Mantle.CreateWorkingConfig(tag: string?)
	MantleConfig.CreateWorkingConfig(tag)
end

function Mantle.GetWorkingConfig(tag: string?): (string, string)
	return MantleConfig.GetWorkingConfig(tag)
end

function Mantle.GetDecodedWorkingConfig(tag: string?): {}
	return MantleConfig:GetDecodedWorkingConfig(tag)
end

function Mantle.SyncInfo(tag: string?)
	local path, environment = MantleConfig.GetWorkingConfig(tag)
	local marketingTable = ExperienceInfo:GetInfo(path, environment)

	Marketing:Sync(marketingTable)
end

function Mantle.SyncInfoOffline(tag: string?)
	local mantleConfig = MantleConfig:GetDecodedWorkingConfig(tag)

	Marketing:OfflineSync(mantleConfig)
end

function Mantle.GetGameLink(tag: string?): string
	local path, environment = MantleConfig.GetWorkingConfig(tag)

	return ExperienceInfo:GetGameLink(path, environment)
end

function Mantle.GetPlaceId(tag: string?): string
	local path, environment = MantleConfig.GetWorkingConfig(tag)

	return ExperienceInfo:GetPlaceId(path, environment)
end

function Mantle.IsPublished(tag: string?): boolean
	local path, environment = MantleConfig.GetWorkingConfig(tag)

	return ExperienceInfo.IsPublished(path, environment)
end

function Mantle.GetInfo(tag: string?): ExperienceInfo.Info
	local path, environment = MantleConfig.GetWorkingConfig(tag)

	return ExperienceInfo:GetInfo(path, environment)
end

return Mantle
