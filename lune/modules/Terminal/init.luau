local process = require("@lune/process")

local config = require("@LuneModules/Config")
local Logger = require("@LuneModules/Terminal/Logger")

export type Terminal = {
	Log: (fileName: string, callback: () -> (), bulkLog: boolean?) -> (),
	StartLogging: (fileName: string?, bulkLog: boolean?) -> (),
	SetLogFileName: (fileName: string) -> (),
	GetLogFileName: () -> string?,
	StopLogging: () -> (),
	Out: (message: string, forcePrint: boolean?) -> (),
	ReadLatestLog: () -> string?,
	execute: (command: string, options: ExecOptions?) -> process.ExecResult,
}

type ExecOptions = process.ExecOptions

local Terminal = {}

function Terminal.Log(fileName: string, callback: () -> (), bulkLog: boolean?)
	Logger:Log(fileName, callback, bulkLog)
end

function Terminal.StartLogging(fileName: string?, bulkLog: boolean?)
	Logger:StartLogging(fileName, bulkLog)
end

function Terminal.SetLogFileName(fileName: string)
	Logger:SetLogFileName(fileName)
end

function Terminal.GetLogFileName(): string?
	return Logger:GetLogFileName()
end

function Terminal.StopLogging()
	Logger:StopLogging()
end

function Terminal.Out(message: string, forcePrint: boolean?)
	Logger:Out(message, forcePrint)
end

function Terminal.ReadLatestLog(): string?
	return Logger:ReadLatestLog()
end

function Terminal.execute(command: string, options: ExecOptions?): process.ExecResult
	local parts = {}
	for part in command:gmatch("%S+") do
		table.insert(parts, part)
	end

	local bin = parts[1]
	local args = {}
	for i = 2, #parts do
		table.insert(args, parts[i])
	end

	local configuredOptions = if options then table.clone(options) else config.EXEC_OPTIONS

	configuredOptions.shell = if configuredOptions.shell == nil or configuredOptions.shell == true then true else nil

	local result = table.clone(process.exec(bin, args, configuredOptions))
	if not result.ok then
		print(`Command failed:\n{result.stderr}\n{result.stdout}`)
	end
	return result
end

return Terminal
