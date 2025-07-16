--[=[ lunar
	about = "[DESCRIPTION] Installs all packages in the project"
]=]

local Packages = require("@LuneModules/Packages")

Packages.Install()
print("Installed packages")

Packages.Copy()
print("Copied packages to out directory")