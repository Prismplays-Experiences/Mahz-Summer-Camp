local pathfs = require("@LunePackages/PathFS")
local fs = pathfs.fs
local Path = pathfs.Path

local Terminal = require("@LuneModules/Terminal")
local Config = require("@LuneModules/Config")

export type Compiler = {
	Observe: (self: Compiler, path: pathfs.Path | string) -> (),
	ObserveDirectory: (self: Compiler, path: pathfs.Path | string) -> (),
	ObserveFile: (self: Compiler, path: pathfs.Path | string) -> (),

	Compile: (self: Compiler, path: pathfs.Path | string) -> (),
	CompileDirectory: (path: pathfs.Path | string) -> (),
	CompileFile: (path: pathfs.Path | string) -> (),
}

local function transformPathIntoPoweshellOne(path: pathfs.Path)
	local resultPowershellPath = `.\\{Config.OUT_PATH}\\`

	for _, component in ipairs(path:components():collect()) do
		resultPowershellPath = resultPowershellPath .. component:toString() .. "\\"
	end

	return resultPowershellPath
end

local Compiler = {}

function Compiler.Observe(self: Compiler, path: pathfs.Path | string)
	if type(path) == "string" then
		path = Path.new(path)
	end

	local entryPath = path :: pathfs.Path

	if fs.isDir(entryPath:toString()) then
		self:ObserveDirectory(entryPath)
	else
		self:ObserveFile(entryPath)
	end
end

function Compiler.ObserveDirectory(self: Compiler, path: pathfs.Path | string)
	pathfs.watchDirectories({ path }, function()
		self.CompileDirectory(path)
	end)
end

function Compiler.ObserveFile(self: Compiler, path: pathfs.Path | string)
	pathfs.watchFile(path, function()
		self.CompileFile(path)
	end)
end

function Compiler.Compile(self: Compiler, path: pathfs.Path | string)
	if type(path) == "string" then
		path = Path.new(path)
	end

	local entryPath = path :: pathfs.Path

	if fs.isDir(entryPath:toString()) then
		self.CompileDirectory(entryPath)
	else
		self.CompileFile(entryPath)
	end
end

function Compiler.CompileDirectory(path: pathfs.Path | string)
	if type(path) == "string" then
		path = Path.new(path)
	end

    local folderPath = path :: pathfs.Path
	local powershellPath = transformPathIntoPoweshellOne(folderPath)

	Terminal.execute(`powershell -Command \"Remove-Item -Path {powershellPath}* -Recurse -Force\"`)
    Terminal.execute(`darklua process {folderPath:toString()} {Config.OUT_PATH.."/"..folderPath:toString()}`)
end

function Compiler.CompileFile(path: pathfs.Path | string)
	if type(path) == "string" then
		path = Path.new(path)
	end

	local filePath = path :: pathfs.Path
	local content = fs.readFile(filePath:toString())

	fs.writeFile(Config.OUT_PATH.."/"..filePath:toString(), content)
end

return Compiler
