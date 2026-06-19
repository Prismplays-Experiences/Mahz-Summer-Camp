--[=[ lunar
	about = "[DESCRIPTION] Syncs assets for the game"
]=]

local Tag = require("@LuneModules/Tag")

if Tag.Get() == "nil" then
	print("No tag set. Please set a tag using the [lune tag] command.")
	return
end

local Assets = require("@LuneModules/Assets")
Assets.Sync()
print("Assets synced successfully")
