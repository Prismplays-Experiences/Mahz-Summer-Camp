local fs = require("@lune/fs")
local serde = require("@lune/serde")

local Terminal = require("@LuneModules/Terminal")

export type MarketingTable = {
	Products: { [string]: { assetId: number, productId: number } },
	Passes: { [string]: number },
}

export type ExperienceInfo = {
	GetGameLink: (self: ExperienceInfo, path: string, environment: string) -> string,
	GetPlaceId: (self: ExperienceInfo, path: string, environment: string) -> string,
	GetMarketingTable: (self: ExperienceInfo, path: string, environment: string) -> MarketingTable,
	IsPublished: (path: string, environment: string) -> boolean,

	_getExperienceInfo: (self: ExperienceInfo, path: string, environment: string) -> { [string]: any },
	_getJson: (path: string, environment: string) -> string,
	_decodeJson: (experienceJson: string) -> { [string]: any },
}

local ExperienceInfo = {}

function ExperienceInfo.GetGameLink(self: ExperienceInfo, path: string, environment: string): string
	local placeId = self:GetPlaceId(path, environment)

	return "https://www.roblox.com/games/" .. placeId
end

function ExperienceInfo.GetPlaceId(self: ExperienceInfo, path: string, environment: string): string
	local experienceInfo = self:_getExperienceInfo(path, environment)

	local placeInfo = experienceInfo.place_start.place
	local placeId = placeInfo.assetId

	placeId = tostring(placeId)

	return placeId
end

function ExperienceInfo.GetMarketingTable(self: ExperienceInfo, path: string, environment: string): MarketingTable
	local experienceInfo = self:_getExperienceInfo(path, environment)

	local marketing: MarketingTable = {
		Products = {},
		Passes = {},
	}

	for key: string, value: { [any]: any } in pairs(experienceInfo) do
		if string.match(key, "product_") then
			marketing.Products[string.sub(key, 9)] = value.product
		elseif string.match(key, "pass_") then
			marketing.Passes[string.sub(key, 6)] = value.pass
		end
	end

	return marketing
end

function ExperienceInfo.IsPublished(path: string, environment: string): boolean
	local result = Terminal.execute(`mantle outputs {path} -e {environment} `)
	local isPublished = not string.match(result.stdout, "{}")

	return isPublished
end

function ExperienceInfo._getExperienceInfo(self: ExperienceInfo, path: string, environment: string): { [string]: any }
	local experienceJson = self._getJson(path, environment)
	local experienceInfo = self._decodeJson(experienceJson)

	return experienceInfo
end

function ExperienceInfo._getJson(path: string, environment: string): string
	Terminal.execute(`mantle outputs {path} -e {environment} -o experience.json`)

	local experienceJson = fs.readFile("experience.json")

	fs.removeFile("experience.json")

	return experienceJson
end

function ExperienceInfo._decodeJson(experienceJson: string): { [string]: any }
	return serde.decode("json", experienceJson)
end

return ExperienceInfo
