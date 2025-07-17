local fs = require("@lune/fs")

local ExperienceInfo = require("@LuneModules/ExperienceInfo")
local TableUtils = require("@LuneModules/TableUtils")
local MantleConfig = require("@LuneModules/MantleConfig")
local Config = require("@LuneModules/Config")
local Terminal = require("@LuneModules/Terminal")

export type MarketingTable = {
	Products: { [string]: { assetId: number, productId: number } },
	Passes: { [string]: number },
}

export type Marketing = {
	Sync: (self: Marketing, tag: string?) -> (),
	OfflineSync: (self: Marketing) -> (),

	_loadSource: (source: string) -> (),
}

local Marketing = {}

function Marketing.Sync(self: Marketing, tag: string?): ()
	local marketingTable: MarketingTable = ExperienceInfo:GetMarketingTable(tag)
	local marketingScriptSource: string = TableUtils.SourcifyMarketing(marketingTable)

	self._loadSource(marketingScriptSource)
end

function Marketing.OfflineSync(self: Marketing): ()
	local mantleConfig: {} = MantleConfig:GetDecodedWorkingConfig()
	local marketingScriptSource: string = TableUtils.SourcifyFakeMarketing(mantleConfig)

	self._loadSource(marketingScriptSource)
end

function Marketing._loadSource(source: string)
	fs.writeFile(Config.MARKETING_SCRIPT_PATH, source)

	Terminal.execute(`stylua {Config.MARKETING_SCRIPT_PATH}`)
end

return Marketing
