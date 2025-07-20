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

local OUT_PATH = Config.GetOutPath()

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

	pathfs.observeDescendantEntry(path, function()
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
	local outFolderPath = OUT_PATH .. "/" .. folderPath:toString()

	if fs.isDir(outFolderPath) then
		fs.removeDir(outFolderPath)
	end

	Terminal.execute(`darklua process {folderPath:toString()} {outFolderPath}`)
end

function Compiler.CompileFile(path: pathfs.Path | string)
	if type(path) == "string" then
		path = Path.new(path)
	end

	local filePath = path :: pathfs.Path

	if filePath:fileStem() == ".placeholder" then
		return
	end

	if filePath:extension() == ".luau" or filePath:extension() == ".lua" then
		Terminal.execute(`darklua process {filePath:toString()} {OUT_PATH .. "/" .. filePath:toString()}`)
		return
	end

	local content = fs.readFile(filePath:toString())

	fs.writeFile(OUT_PATH .. "/" .. filePath:toString(), content)
end

return Compiler
