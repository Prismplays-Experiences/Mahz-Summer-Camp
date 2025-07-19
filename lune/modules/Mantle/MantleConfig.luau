local fs = require("@lune/fs")
local serde = require("@lune/serde")

local Tag = require("@LuneModules/Tag")
local Config = require("@LuneModules/Config")

local GAME_SUFFIX = "24-days-to-lose-weight"

export type MantleConfig = {
	target: {
		experience: {
			products: {},
			passes: {},
		},
	},
}

export type MantleConfigModule = {
	CreateWorkingConfig: (tag: string?) -> (),
	GetWorkingConfig: (tag: string?) -> (string, string),
	GetDecodedWorkingConfig: (self: MantleConfigModule, tag: string?) -> {},
}

local MantleConfig = {}

function MantleConfig.CreateWorkingConfig(tag: string?)
	tag = tag or Tag.Get()

	local templateFile = fs.readFile("dev-mantle.yml")

	local gameConfig = serde.decode("yaml", templateFile)

	gameConfig.environments[1].branches = nil
	gameConfig.environments[1].label = tag
	gameConfig.owner.group = Config.GROUPS.feature.id

	gameConfig.state.remote.key = `{tag} - {GAME_SUFFIX}`

	local gameConfigEncoded = serde.encode("yaml", gameConfig)

	fs.writeFile("feature-mantle.yml", gameConfigEncoded)
end

function MantleConfig.GetWorkingConfig(tag: string?): (string, string)
	tag = tag or Tag.Get()

	if tag == nil or tag == "nil" then
		return "dev-mantle.yml", "dev"
	end

	local path = tag

	if string.match(path, "feature_") then
		path = "feature"
	end

	path = path .. "-mantle.yml"

	return path, tag
end

function MantleConfig.GetDecodedWorkingConfig(self: MantleConfigModule, tag: string?): {}
	local mantleConfigPath = self.GetWorkingConfig(tag)
	local mantleConfig = fs.readFile(mantleConfigPath)

	mantleConfig = serde.decode("yaml", mantleConfig)

	return mantleConfig
end

return MantleConfig
