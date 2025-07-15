--[=[ lunar
	about = "[DESCRIPTION] Adds given package to the project and then installs it"
    args = "<USERNAME/PACKAGE_NAME> — username of creator and package name which you want to install\n\n[OPTIONAL]\n--pesde/-p if you want to install a package from pesde, not wally \n--target/-t <TARGET_NAME (lune/luau)> if you want to install lune/luau packages. Defaults to roblox target"
]=]

local process = require("@lune/process")

local Packages = require("./modules/Packages")

local isWally = nil
local packageName = nil
local target = nil

local args = process.args

packageName = args[2]

for index, arg in pairs(args) do
    if arg == "--pesde" or arg == "-p" then
        isWally = false
    elseif arg == "--target" or arg == "-t" then
        target = args[index + 1]
    end
end

Packages.Add(packageName, isWally, target)
print("Added package:", packageName)

Packages.Install()
print("Installed packages")

if target ~= "roblox" then
    return
end

Packages.Copy()
print("Copied packages to out")

