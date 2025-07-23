---@diagnostic disable: undefined-type
-- Not the official TableUtils module, but a custom one for Lune

export type PlaceInfo = {
	Id: number,
	Version: number,
}

export type Info = {
	Products: { [string]: { assetId: number, productId: number } },
	Passes: { [string]: number },
	Places: {
		MainGame: PlaceInfo,
		Lobby: PlaceInfo,
	},
	ExperienceId: number,
}

export type TableUtils<T, S> = {
	SourcifyMarketing: (marketingTable: Info) -> string,
	SourcifyExperienceInfo: (marketingTable: Info) -> string,
	Sourcify: (self: TableUtils<T, S>, tbl: T) -> string,
	Copy: (t: T, deep: boolean?) -> T,
	Reconcile: (self: TableUtils<T, S>, src: S, template: T) -> S & T,
	Extend: (target: { T }, extension: { S }) -> { T } & { S },
	Find: (tbl: { [T]: S }, callback: (S, T, { [T]: S }) -> boolean) -> (S?, T?),
	NestedMap: (
		tbl: {},
		tblKey: any,
		tblChildrenName: string,
		callback: (...any) -> {},
		childrenName: string?,
		childKeyCallback: ((index: number, ...any) -> any)?
	) -> {},

	_recursiveSourcify: (self: TableUtils<T, S>, tbl: T) -> string,
}

local FAKE_ID = 111111111 -- Placeholder for fake asset IDs
local FAKE_PLACE_ID = 0 -- Placeholder for fake place IDs
local FAKE_PLACE_VERSION = 0 -- Placeholder for fake place version
local FAKE_EXPERIENCE_ID = 0 -- Placeholder for fake experience ID

local function sourcifyProductsPasses(
	result: string,
	marketingType: "Products" | "Passes",
	originalKey: string,
	originalValue: { assetId: number, productId: number? }
): string
	local key = ("[%q]"):format(originalKey)
	local value

	if marketingType == "Products" then
		value = "{assetId = "
			.. tostring(originalValue.assetId)
			.. ", productId = "
			.. tostring(originalValue.productId)
			.. "}"
	elseif marketingType == "Passes" then
		value = tostring(originalValue.assetId)
	end

	result = result .. key .. " = " .. value .. ",\n"

	return result
end

local function sourcifyPlaceInfo(result: string, key: string, value: PlaceInfo): string
	local placeValue = "{Id = " .. tostring(value.Id) .. ", Version = " .. tostring(value.Version) .. "}"
	result = result .. key .. " = " .. placeValue .. ",\n"
	return result
end

local TableUtils = {}

function TableUtils.SourcifyMarketing(marketingTable: Info): string
	local result = "return { \n"

	for marketingType, marketingValues in pairs(marketingTable) do
		if marketingType == "Places" or marketingType == "ExperienceId" then
			continue
		end

		result = result .. marketingType .. " = "

		if type(marketingValues) == "table" then
			result = result .. "{ \n"

			for k, v in pairs(marketingValues) do
				if marketingType == "Products" or marketingType == "Passes" then
					result = sourcifyProductsPasses(result, marketingType, k, v)
				end
			end

			result = result .. "}"
		end

		result = result .. ","
	end

	result = result:sub(1, -2)
	result = result .. "}\n"

	return result
end

function TableUtils.SourcifyExperienceInfo(marketingTable: Info): string
	local result = "return { \n"

	for marketingType, marketingValues in pairs(marketingTable) do
		if marketingType == "Products" or marketingType == "Passes" then
			continue
		end

		result = result .. marketingType .. " = "

		if type(marketingValues) == "table" then
			result = result .. "{ \n"

			for k, v in pairs(marketingValues) do
				result = sourcifyPlaceInfo(result, k, v)
			end

			result = result .. "}"
		elseif marketingType == "ExperienceId" then
			result = result .. tostring(marketingValues) .. ""
		end

		result = result .. ","
	end

	result = result:sub(1, -2)
	result = result .. "}\n"

	return result
end

function TableUtils.SourcifyFakeMarketing(mantleConfig: { [any]: any })
	local experienceInfo = mantleConfig.target.experience

	local result = "return { \n"
	result = result .. "Products = { \n"

	for productName, _ in pairs(experienceInfo.products or {}) do
		local key = ("[%q]"):format(productName)
		local value = "{assetId = " .. FAKE_ID .. ", productId = " .. FAKE_ID .. "}"
		result = result .. key .. " = " .. value .. ",\n"
	end

	result = result .. "},\n"
	result = result .. "Passes = { \n"

	for passName, _ in pairs(experienceInfo.passes or {}) do
		local key = ("[%q]"):format(passName)
		local value = FAKE_ID
		result = result .. key .. " = " .. value .. ",\n"
	end

	result = result .. "}\n"
	result = result .. "}"

	return result
end

function TableUtils.SourcifyFakeExperienceInfo()
	local result = "return { \n"

	result = result .. "Places = {\n"
	result = result .. "MainGame = {Id = " .. FAKE_PLACE_ID .. ", Version = " .. FAKE_PLACE_VERSION .. "},\n"
	result = result .. "Lobby = {Id = " .. FAKE_PLACE_ID .. ", Version = " .. FAKE_PLACE_VERSION .. "},\n"
	result = result .. "},\n"

	result = result .. "ExperienceId = " .. FAKE_EXPERIENCE_ID .. "\n"

	result = result .. "}"

	return result
end

function TableUtils.Sourcify<T>(self: TableUtils<T, any>, tbl: T): string
	local source = self:_recursiveSourcify(tbl)

	return "return " .. source
end

function TableUtils.Copy<T>(t: T, deep: boolean?): T
	if not deep then
		return (table.clone(t :: any) :: any) :: T
	end

	local function DeepCopy(tbl: { any })
		local tCopy = table.clone(tbl)
		for k, v in tCopy do
			if type(v) == "table" then
				tCopy[k] = DeepCopy(v)
			end
		end
		return tCopy
	end

	return DeepCopy(t :: any) :: T
end

function TableUtils.Reconcile<S, T>(self: TableUtils<T, S>, src: S, template: T): S & T
	assert(type(src) == "table", "First argument must be a table")
	assert(type(template) == "table", "Second argument must be a table")

	local tbl = table.clone(src)

	for k, v in template do
		local sv = src[k]
		if sv == nil then
			if type(v) == "table" then
				tbl[k] = self.Copy(v, true)
			else
				tbl[k] = v
			end
		elseif type(sv) == "table" then
			if type(v) == "table" then
				tbl[k] = self:Reconcile(sv, v)
			else
				tbl[k] = self.Copy(sv, true)
			end
		end
	end

	return (tbl :: any) :: S & T
end

function TableUtils.NestedMap(
	tbl: {},
	tblKey: any,
	tblChildrenName: string,
	callback: (...any) -> {},
	childrenName: string?,
	childKeyCallback: ((index: number, ...any) -> any)?
): {}
	childrenName = childrenName or "children"

	local keyCallback: any = childKeyCallback or function(index: number)
		return index
	end

	local function mapComponent(value: {}, key: any)
		local tree = {}

		tree = callback(value, key)
		tree[childrenName] = {}

		local index = 0
		for childKey, childValue in pairs(value[tblChildrenName]) do
			index += 1

			local newChildKey = keyCallback(index, childKey, childValue)

			tree[childrenName][newChildKey] = mapComponent(childValue, childKey)
		end

		return tree
	end

	local result = mapComponent(tbl, tblKey)

	return result
end

function TableUtils.Extend<T, E>(target: { T }, extension: { E }): { T } & { E }
	local tbl = table.clone(target) :: { any }
	for _, v in extension do
		table.insert(tbl, v)
	end
	return tbl
end

function TableUtils.Find<K, V>(tbl: { [K]: V }, callback: (V, K, { [K]: V }) -> boolean): (V?, K?)
	for k, v in tbl do
		if callback(v, k, tbl) then
			return v, k
		end
	end
	return nil, nil
end

function TableUtils._recursiveSourcify<T>(self: TableUtils<T, nil>, tbl: {}): string
	local source = "{\n"

	for key, value in pairs(tbl) do
		if type(value) == "table" then
			source = source .. tostring(key) .. "=" .. self:_recursiveSourcify(value)
		else
			source = source .. tostring(key) .. "= '" .. tostring(value) .. "'"
		end

		source = source .. ",\n"
	end

	source = source .. "}"

	return source
end

return TableUtils
