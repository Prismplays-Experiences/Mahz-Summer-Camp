local PathUtils = require("@LuneModules/PathUtils")
local Compiler = require("@LuneModules/Compiler")
local Test = {}

function Test.Run()
    local entries = PathUtils:GetDescendantEntries("src/MainGame/StarterPlayerScripts/Controllers")
    local paths = PathUtils.EntriesToPaths(entries)

    PathUtils.Observe(paths, function(path)
        Compiler:Compile(path)
    end)
end

return Test