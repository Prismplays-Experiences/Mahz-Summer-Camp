local Config = require("@LuneModules/Config")
local Env = require("@LuneModules/Env")

export type Tag = {
	Set: (self: Tag, value: any) -> (),
	Get: () -> any,

	_getApiKey: (self: Tag) -> string?,
}

local Tag = {}

function Tag.Set(self: Tag, value: any): ()
	Env:Set("TAG", value)
	Env:Set("MANTLE_OPEN_CLOUD_API_KEY", self:_getApiKey())
end

function Tag.Get(): any
	return Env:Get("TAG")
end

function Tag._getApiKey(self: Tag): string?
	local tag = self.Get()

	if not tag then
		return
	end

	local group = if string.match(tag, "feature_") then "SCRIPTING" elseif tag == "prod" then "PROD" else "DEV"

	local apiKey = Config[group .. "_GROUP_API_KEY"]

	return apiKey
end

return Tag
