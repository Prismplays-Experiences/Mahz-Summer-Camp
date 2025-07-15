local fs = require("@lune/fs")

export type Logger = {
	Log: (self: Logger, fileName: string, callback: () -> (), bulkLog: boolean?) -> (),
	StartLogging: (self: Logger, fileName: string?, bulkLog: boolean?) -> (),
	SetLogFileName: (self: Logger, fileName: string) -> (),
	GetLogFileName: (self: Logger) -> string?,
	GetMemory: (self: Logger) -> string?,
	StopLogging: (self: Logger) -> (),
	Out: (self: Logger, message: string, forcePrint: boolean?) -> (),
	ReadLatestLog: (self: Logger) -> string?,

	_addNewLineToLog: (self: Logger, line: string) -> (),
	_writeToLog: (self: Logger, message: string) -> (),
    _createNewLog: (self: Logger) -> string,
	_getLogCount: (self: Logger) -> number,

	_loggingEnabled: boolean,
	_logFileName: string?,
	_memory: string?,
}

local LOG_FOLDER_PATH = "logs/%s"
local LOG_PATH = LOG_FOLDER_PATH.."/%d.log"

local Logger = {}
Logger._loggingEnabled = false
Logger._logFileName = nil
Logger._memory = nil

function Logger.Log(self: Logger, fileName: string, callback: () -> (), bulkLog: boolean?)
	self:StartLogging(fileName, bulkLog)

	callback()

	self:StopLogging()
end

function Logger.StartLogging(self: Logger, logFileName: string?, bulkLog: boolean?)
	self._loggingEnabled = true

	if logFileName then
		self:SetLogFileName(logFileName)
	end

	if bulkLog then
		self._memory = ""
		return
	end

    self:_createNewLog()
end

function Logger.SetLogFileName(self: Logger, fileName: string)
	if fileName and fileName ~= "" then
		self._logFileName = fileName

        fs.writeDir(LOG_FOLDER_PATH:format(fileName))
	else
		error("Invalid log file name provided.")
	end
end

function Logger.GetLogFileName(self: Logger): string?
	if not self._logFileName then
		error("Log file name is not set. Please set it using SetLogFileName.")
	end

	return self._logFileName
end

function Logger.StopLogging(self: Logger)
	if self:GetMemory() then
		local memory = (self:GetMemory() :: string):sub(1, -2)
		self._memory = nil

		self:_createNewLog()
		self:_writeToLog(memory)
	end

	self._loggingEnabled = false
end

function Logger.Out(self: Logger, message: string, forcePrint: boolean?)
	if not self._loggingEnabled or forcePrint then
		print(`[INFO]`, message)

		return
	end

	if self:GetMemory() then
		self._memory = (self:GetMemory() :: string) .. message .. "\n"
		return
	end

	self:_addNewLineToLog(message)
end

function Logger.ReadLatestLog(self: Logger): string?
	if not self._loggingEnabled then
		return nil
	end

	local logIndex = self:_getLogCount()
	local logFileName = self:GetLogFileName()
	local logFilePath = LOG_PATH:format(logFileName, logIndex)

	if not fs.isFile(logFilePath) then
		return nil
	end

	return fs.readFile(logFilePath)
end

function Logger.GetMemory(self: Logger): string?
	return self._memory
end

function Logger._addNewLineToLog(self: Logger, line: string)
	local logContent = self:ReadLatestLog() or ""
	local newLogContent = logContent .. line

	self:_writeToLog(newLogContent)
end

function Logger._writeToLog(self: Logger, message: string)
	if not self._loggingEnabled then
		return
	end

	local logIndex = self:_getLogCount()
	local logFileName = self:GetLogFileName()
	local logFilePath = LOG_PATH:format(logFileName, logIndex)

	fs.writeFile(logFilePath, message .. "\n")
end

function Logger._createNewLog(self: Logger): string
    local logFileName = self:GetLogFileName()
    local logIndex = self:_getLogCount() + 1
    local logFilePath = LOG_PATH:format(logFileName, logIndex)

    fs.writeFile(logFilePath, "")

    return logFilePath
end

function Logger._getLogCount(self: Logger): number
	local fileName = self:GetLogFileName()

    local logs = fs.readDir(LOG_FOLDER_PATH:format(fileName))

	return #logs
end

return Logger :: Logger