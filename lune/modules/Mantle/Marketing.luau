local fs = require("@lune/fs")

local TableUtils = require("@LuneModules/TableUtils")
local Config = require("@LuneModules/Config")
local Terminal = require("@LuneModules/Terminal")
local Compiler = require("@LuneModules/Compiler")

export type MarketingTable = {
	Products: { [string]: { assetId: number, productId: number } },
	Passes: { [string]: number },
}

export type Marketing = {
	Sync: (self: Marketing, marketingTable: MarketingTable) -> (),
	OfflineSync: (self: Marketing, mantleConfig: { [any]: any }) -> (),

	_loadMarketing: (source: string) -> (),
	_loadExperienceInfo: (source: string) -> (),
}

local Marketing = {}

function Marketing.Sync(self: Marketing, marketingTable: { [any]: any }): ()
	local marketingSource = TableUtils.SourcifyMarketing(marketingTable)
	local experienceInfoSource = TableUtils.SourcifyExperienceInfo(marketingTable)

	self._loadMarketing(marketingSource)
	self._loadExperienceInfo(experienceInfoSource)
end

function Marketing.OfflineSync(self: Marketing, mantleConfig: { [any]: any }): ()
	local marketingSource: string = TableUtils.SourcifyFakeMarketing(mantleConfig)
	local experienceInfoSource: string = TableUtils.SourcifyFakeExperienceInfo()

	self._loadMarketing(marketingSource)
	self._loadExperienceInfo(experienceInfoSource)
end

function Marketing._loadMarketing(source: string)
	local path = Config:GetMarketingOutPath()
	fs.writeFile(path, source)

	Compiler.CompileFile(path)
	Terminal.execute(`stylua {path}`)
end

function Marketing._loadExperienceInfo(source: string)
	local path = Config:GetExperienceInfoOutPath()
	fs.writeFile(path, source)

	Compiler.CompileFile(path)
	Terminal.execute(`stylua {path}`)
end

return Marketing
