local fs = require("@lune/fs")

local Config = require("@LuneModules/Config")
local TableUtils = require("@LuneModules/TableUtils")

export type Env = {
	env: { [string]: any },
	Set: (self: Env, key: string, value: any) -> (),
	Get: (self: Env, key: string) -> any,

	_updateEnvFile: (self: Env) -> (),
	_reconcileEnvFile: (self: Env) -> (),
	_serializeEnv: (self: Env) -> string,
}

local ENV_VARIABLES = Config.GetEnv()

local Env = {}

Env.env = ENV_VARIABLES

function Env.Set(self: Env, key: string, value: any): ()
	assert(type(key) == "string", "Key must be a string")

	self.env[key] = value

	self:_updateEnvFile()
end

function Env.Get(self: Env, key: string): any
	self:_reconcileEnvFile()

	return self.env[key]
end

function Env._updateEnvFile(self: Env)
	fs.writeFile(".env", self:_serializeEnv())
end

function Env._reconcileEnvFile(self: Env)
	if fs.isFile(".env") == false then
		return
	end

	local envFileContent = fs.readFile(".env")

	local lines = {}
	for line in string.gmatch(envFileContent, "[^\n]+") do
		local key, value = line:match("^(.-)=(.*)$")
		if key and value then
			lines[key] = value
		end
	end

	self.env = TableUtils:Reconcile(self.env, lines)
end

function Env._serializeEnv(self: Env): string
	local lines = {}

	for key, value in pairs(self.env) do
		if type(value) == "string" then
			table.insert(lines, key .. "=" .. value)
		elseif type(value) == "number" or type(value) == "boolean" then
			table.insert(lines, key .. "=" .. tostring(value))
		else
			error("Unsupported value type for environment variable: " .. tostring(type(value)))
		end
	end

	return table.concat(lines, "\n")
end

return Env
