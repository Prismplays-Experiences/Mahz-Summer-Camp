local fs = require("@lune/fs")

local Terminal = require("./Terminal")
local TablesUtils = require("./TableUtils")
local Tag = require("./Tag")

local config = require("../config")

local Assets = {}

function Assets.Sync(self: {}, devAssets: {}, featureAssets: {}, tag: string?)
	local source = self._getSource(devAssets, featureAssets, tag)

	fs.writeFile(config.ASSETS_PATH, source)

	Terminal.execute(`stylua {config.ASSETS_PATH}`)
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
