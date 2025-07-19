local fs = require("@lune/fs")

local TableUtils = require("@LuneModules/TableUtils")
local Config = require("@LuneModules/Config")
local Terminal = require("@LuneModules/Terminal")

export type MarketingTable = {
	Products: { [string]: { assetId: number, productId: number } },
	Passes: { [string]: number },
}

export type Marketing = {
	Sync: (self: Marketing, marketingTable: MarketingTable) -> (),
	OfflineSync: (self: Marketing, mantleConfig: { [any]: any }) -> (),

	_loadSource: (source: string) -> (),
}

local Marketing = {}

function Marketing.Sync(self: Marketing, marketingTable: MarketingTable): ()
	local marketingScriptSource: string = TableUtils.SourcifyMarketing(marketingTable)

	self._loadSource(marketingScriptSource)
end

function Marketing.OfflineSync(self: Marketing, mantleConfig: { [any]: any }): ()
	local marketingScriptSource: string = TableUtils.SourcifyFakeMarketing(mantleConfig)

	self._loadSource(marketingScriptSource)
end

function Marketing._loadSource(source: string)
	local path = `src/{Config.MARKETING_SCRIPT_PATH}`
	fs.writeFile(path, source)

	Terminal.execute(`stylua {path}`)
end

return Marketing
