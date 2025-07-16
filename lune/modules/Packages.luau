local fs = require("@lune/fs")

local Terminal = require("@LuneModules/Terminal")

local Packages = {}

function Packages.Install()
	Terminal.execute("pesde install")
end

function Packages.Copy()
	local writeOptions: fs.WriteOptions = {
		overwrite = true,
	}

	fs.copy("roblox_packages", "out/roblox_packages", writeOptions)
end

function Packages.Add(packageName: string, isWally: boolean?, target: "lune" | "luau" | "roblox" | nil)
	isWally = if isWally == nil then true else false

	if not packageName then
		error("Package name is required!")

		return
	end

	local fullPackageName = `{if isWally then "wally#" else "" }{packageName}`
	local targetArg = if target and target ~= "roblox" then "-t ".. target else ""

	Terminal.execute(`pesde add {fullPackageName} {targetArg}`)
end

return Packages
