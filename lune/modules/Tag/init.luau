local Env = require("@LuneModules/Tag/Env")
local TagManager = require("@LuneModules/Tag/TagManager")

local Assets = require("@LuneModules/Assets")
local Config = require("@LuneModules/Config")

export type Tag = {
	Set: (self: Tag, newTag: string) -> string,
	Get: (cropped: boolean?) -> string,

	_getGroupId: (self: Tag) -> number?,
	_getApiKey: (self: Tag) -> string?,
	_getGroupInfo: (self: Tag) -> { [string]: any }?,
	_cropTag: (tag: string) -> string,
}

local Tag = {}

function Tag.Set(self: Tag, newTag: string): string
	local previousTag = self.Get(true)
	local newTagCropped = self._cropTag(newTag)

	TagManager.Set(newTag)

	local groupId = self:_getGroupId() :: number
	local apiKey = self:_getApiKey()

	Env:Set("MANTLE_OPEN_CLOUD_API_KEY", apiKey)
	Env:Set("ASPHALT_API_KEY", apiKey)

	Assets.SetId(groupId)

	if previousTag ~= "nil" then
		Assets.SaveLock(previousTag)
	end

	Assets.LoadLock(newTagCropped)

	return previousTag
end

function Tag.Get(cropped: boolean?): string
	local tag = TagManager.Get()

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
	local tag = self.Get(true)

	if not tag then
		return
	end

	return Config.GetGroupInfo(tag)
end

function Tag._cropTag(tag: string): string
	if string.match(tag, "feature_") then
		return "feature"
	end

	return tag
end

return Tag
