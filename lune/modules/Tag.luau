local Config = require("@LuneModules/Config")
local Env = require("@LuneModules/Env")
local Assets = require("@LuneModules/Assets/init")

export type Tag = {
	Set: (self: Tag, newTag: string) -> (),
	Get: (cropped: boolean?) -> string,

	_getGroupId: (self: Tag) -> number?,
	_getApiKey: (self: Tag) -> string?,
	_getGroupInfo: (self: Tag) -> { [string]: any }?,
	_cropTag: (tag: string) -> string,
}

local Tag = {}

function Tag.Set(self: Tag, newTag: string): ()
	local previousTag = self.Get(true)
	local newTagCropped = self._cropTag(newTag)

	Env:Set("TAG", newTag)
	Env:Set("MANTLE_OPEN_CLOUD_API_KEY", self:_getApiKey())
	Env:Set("ASPHALT_API_KEY", self:_getApiKey())
	Assets.SetId(self:_getGroupId() :: number)

	Assets.SaveLock(previousTag)
	Assets.LoadLock(newTagCropped)
end

function Tag.Get(cropped: boolean?): string
	local tag = Env:Get("TAG")

	if cropped then
		tag = Tag._cropTag(tag)
	end

	return tag
end

function Tag._getGroupId(self: Tag): number?
	local groupInfo = self:_getGroupInfo()

	if not groupInfo then
		return nil
	end

	return groupInfo.id
end

function Tag._getApiKey(self: Tag): string?
	local groupInfo = self:_getGroupInfo()

	if not groupInfo then
		return nil
	end

	local apiKey = groupInfo.apiKey

	return apiKey
end

function Tag._getGroupInfo(self: Tag): { [string]: any }?
	local tag = self.Get()

	if not tag then
		return
	end

	if string.match(tag, "feature_") then
		tag = "feature"
	end

	return Config.GROUPS[tag]
end

function Tag._cropTag(tag: string): string
	if string.match(tag, "feature_") then
		return "feature"
	end

	return tag
end

return Tag
