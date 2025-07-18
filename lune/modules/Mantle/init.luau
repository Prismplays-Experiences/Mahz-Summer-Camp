local DeployManager = require("@LuneModules/Mantle/DeployManager")
local MantleConfig = require("@LuneModules/Mantle/MantleConfig")
local Marketing = require("@LuneModules/Mantle/Marketing")
local ExperienceInfo = require("@LuneModules/Mantle/ExperienceInfo")

local Mantle = {}

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

function Mantle.SyncMarketing(tag: string?)
    local path, environment = MantleConfig.GetWorkingConfig(tag)
    local marketingTable = ExperienceInfo:GetMarketingTable(path, environment)

    Marketing:Sync(marketingTable)
end

function Mantle.SyncMarketingOffline(tag: string?)
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

function Mantle.GetMarketingTable(tag: string?): ExperienceInfo.MarketingTable
    local path, environment = MantleConfig.GetWorkingConfig(tag)

    return ExperienceInfo:GetMarketingTable(path, environment)
end

return Mantle