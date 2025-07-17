local fs = require("@lune/fs")

local Terminal = require("./Terminal")
local TablesUtils = require("./TableUtils")
local Tag = require("./Tag")

local Config = require("@LuneModules/Config")

export type Assets = {
	Sync: (self: Assets, devAssets: {}, featureAssets: {}, tag: string?) -> (),

	_getSource: (devAssets: {}, featureAssets: {}, tag: string?) -> string,
}

local ASSETS_PATH = Config.SRC_PATH .. "/" .. Config.PROJECT:sub(1, -14) .. "/" .. Config.ASSETS_PATH

local Assets = {}

function Assets.Sync(self: Assets, devAssets: {}, featureAssets: {}, tag: string?)
	local source = self._getSource(devAssets, featureAssets, tag)

	fs.writeFile(ASSETS_PATH, source)

	Terminal.execute(`stylua {ASSETS_PATH}`)
end

function Assets._getSource(devAssets: {}, featureAssets: {}, tag: string?)
	tag = tag or Tag.Get()

	local source

	if tag == "dev" or tag == "prod" then
		local assetsTemplatePath = `Assets/{tag}-assets.luau`
		source = fs.readFile(assetsTemplatePath)
	else
		featureAssets = TablesUtils:Reconcile(featureAssets, devAssets)
		source = TablesUtils:Sourcify(featureAssets)
	end

	return source
end

return Assets
