local serde = require("@lune/serde")

local pathfs = require("@LunePackages/pathfs")
local fs = pathfs.fs

local Config = require("@LuneModules/Config")

local CONFIG_PATH = Config.ASSETS_CONFIG_PATH

export type AssetsConfigModule = {
    SetId: (self: AssetsConfigModule, id: number) -> (),
    GetDecodedConfig: () -> { [string]: any },
    UpdateConfig: (config: { [string]: any }) -> (),
}

local AssetsConfig = {}

function AssetsConfig.SetId(self: AssetsConfigModule, id: number)
    local config = self.GetDecodedConfig()

    config.creator.id = id

    self.UpdateConfig(config)
end

function AssetsConfig.GetDecodedConfig(): { [string]: any }
    local configContent = fs.readFile(CONFIG_PATH)
    local decodedConfig = serde.decode("toml", configContent)

    return decodedConfig
end

function AssetsConfig.UpdateConfig(config: { [string]: any })
    local encodedConfig = serde.encode("toml", config, true)
    fs.writeFile(CONFIG_PATH, encodedConfig)
end

return AssetsConfig
