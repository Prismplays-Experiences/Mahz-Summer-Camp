local ConfigFile = require("@LuneModules/Config/ConfigFile")
local process = require("@lune/process")

export type Config = {
	GetProjectPath: (self: Config, place: string?) -> string,
	GetGamePath: (self: Config, place: string?) -> string,
	GetSourcemapPath: () -> string,
	GetOutSrcPath: (self: Config, place: string?) -> string,
	GetOutPath: () -> string,
	GetSrc: (self: Config, place: string?) -> string,
	GetObjectsPath: (self: Config, place: string?) -> string,

	GetExecOptions: () -> process.ExecOptions,

	GetAssetsConfigPath: () -> string,
	GetAssetsLockPath: (tag: string?) -> string,

	GetEnv: () -> { [string]: string },

	SetPlace: (place: string) -> (),
	GetAllPlaces: () -> { string },
	GetCurrentPlace: () -> string,

	GetGroupInfo: (tag: string) -> { id: number, apiKey: string },

	GetMarketingOutPath: (self: Config) -> string,
}

local Config = {}

function Config.GetMarketingOutPath(self: Config): string
	local config = ConfigFile.Get()
	local marketingOutPath = config.mantle.marketing_out_path
	local srcPath = self:GetSrc("Mutuals")
	local fullPath = `{srcPath}/{marketingOutPath}`

	return fullPath
end

function Config.GetGroupInfo(tag: string): { id: number, apiKey: string }
	local config = ConfigFile.Get()
	local groupInfo = config.groups[tag]

	return groupInfo
end

function Config.SetPlace(place: string): ()
	ConfigFile:Update(function(content: ConfigFile.ConfigFile)
		content.multiplace.current_place = place

		return content
	end)
end

function Config.GetAllPlaces(): { string }
	local config = ConfigFile.Get()
	local places = config.multiplace.places

	return places
end

function Config.GetEnv(): { [string]: string }
	local config = ConfigFile.Get()
	local env = config.env

	return env
end

function Config.GetAssetsLockPath(tag: string?): string
	tag = tag

	local config = ConfigFile.Get()
	local assetsLockPath = config.assets.lock_path:format(tag)

	return assetsLockPath
end

function Config.GetAssetsConfigPath(): string
	local config = ConfigFile.Get()
	local assetsConfigPath = config.assets.config_path

	return assetsConfigPath
end

function Config.GetExecOptions(): process.ExecOptions
	local config = ConfigFile.Get()

	return config.executor
end

function Config.GetGamePath(self: Config, place: string?): string
	place = place or self.GetCurrentPlace()

	local config = ConfigFile.Get()
	local gamePath = config.structure.game:format(place)

	return gamePath
end

function Config.GetProjectPath(self: Config, place: string?): string
	place = place or self.GetCurrentPlace()

	local config = ConfigFile.Get()
	local projectPath = config.structure.project:format(place)

	return projectPath
end

function Config.GetSourcemapPath(): string
	local config = ConfigFile.Get()
	local sourcemapPath = config.structure.sourcemap

	return sourcemapPath
end

function Config.GetOutSrcPath(self: Config, place: string?): string
	local outPath = self.GetOutPath()
	local srcPath = self:GetSrc(place)

	local outSrcPath = `{outPath}/{srcPath}`

	return outSrcPath
end

function Config.GetOutPath(): string
	local config = ConfigFile.Get()
	local outPath = config.structure.out_path

	return outPath
end

function Config.GetSrc(self: Config, place: string?): string
	place = place or self.GetCurrentPlace()

	local config = ConfigFile.Get()
	local srcPath = config.structure.src_path:format(place)

	return srcPath
end

function Config.GetObjectsPath(self: Config, place: string?): string
	place = place or self.GetCurrentPlace()

	local config = ConfigFile.Get()
	local objectsPath = config.structure.objects_path:format(place)

	return objectsPath
end

function Config.GetCurrentPlace(): string
	local config = ConfigFile.Get()

	return config.multiplace.current_place
end

return Config
