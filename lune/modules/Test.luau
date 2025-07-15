local pathfs = require("@LunePackages/PathFS")
local Test = {}

function Test.Run()
    pathfs.watchDirectories({"src/server"}, function()
        print("Changed")
    end)
end

return Test