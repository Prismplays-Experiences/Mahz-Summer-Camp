local process = require("@lune/process")
local fs = require("@lune/fs")

local Config = require("@LuneModules/Config")

local args = process.args
local place = "MainGame"

for _, arg in pairs(args) do
	for _, placeName in ipairs(Config.PLACES) do
        if arg == placeName then
            place = placeName
            break
        end
    end
end

local configContent = fs.readFile("lune/modules/Config.luau")

for _, placeName in ipairs(Config.PLACES) do
    configContent = configContent:gsub('config.PROJECT = "' .. placeName .. '.project.json"', 'config.PROJECT = "' .. place .. '.project.json"')
    configContent = configContent:gsub('config.OBJECTS_PATH = "objects/' .. placeName .. '"', 'config.OBJECTS_PATH = "objects/' .. place .. '"')
end

fs.writeFile("lune/modules/Config.luau", configContent)