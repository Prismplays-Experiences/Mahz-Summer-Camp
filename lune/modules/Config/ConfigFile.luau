local fs = require("@lune/fs")
local serde = require("@lune/serde")

local CONFIG_PATH = "lune/config.toml"

type GroupInfo = {
	id: number,
	apiKey: string,
}

export type ConfigFile = {
	structure: {
		objects_path: string,
		src_path: string,
		out_path: string,
		sourcemap: string,
		game: string,
		project: string,
	},
	executor: {
		shell: boolean,
		stdio: string,
	},
	assets: {
		config_path: string,
		lock_path: string,
	},
	mantle: {
		marketing_out_path: string,
	},
	multiplace: {
		places: { string },
		current_place: string,
	},
	env: {
		MANTLE_AWS_ACCESS_KEY_ID: string,
		MANTLE_AWS_SECRET_ACCESS_KEY: string,
	},
	groups: {
		dev: GroupInfo,
		feature: GroupInfo,
		prod: GroupInfo,
	},
}

export type ConfigFileModule = {
	Update: (self: ConfigFileModule, callback: (content: ConfigFile) -> ConfigFile) -> (),
	Get: () -> ConfigFile,
	Set: (content: ConfigFile) -> (),
}

local ConfigFile = {}

function ConfigFile.Update(self: ConfigFileModule, callback: (content: ConfigFile) -> ConfigFile)
	local content = self.Get()
	local updatedContent = callback(content)

	self.Set(updatedContent)
end

function ConfigFile.Get(): ConfigFile
	local content = fs.readFile(CONFIG_PATH)
	local decodedContent = serde.decode("toml", content)

	return decodedContent
end

function ConfigFile.Set(content: ConfigFile)
	local encodedContent = serde.encode("toml", content, true)

	fs.writeFile(CONFIG_PATH, encodedContent)
end

return ConfigFile
