local AssetsConfig = require("@LuneModules/Assets/AssetsConfig")
local AssetsModule = require("@LuneModules/Assets/AssetsModule")
local AssetsLock = require("@LuneModules/Assets/AssetsLock")

local Assets = {}

function Assets.SetId(id: number)
	AssetsConfig:SetId(id)
end

function Assets.Sync()
	AssetsModule.Sync()
end

function Assets.SaveLock(tag: string?)
	AssetsLock:Save(tag)
end

function Assets.LoadLock(tag: string?)
	AssetsLock:Load(tag)
end

return Assets
