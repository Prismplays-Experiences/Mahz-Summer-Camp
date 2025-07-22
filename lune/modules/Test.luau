local GameManager = require("@LuneModules/GameManager")

local Test = {}

function Test.Run()
    local game = GameManager.GetGame()

    game:GetService("Lighting").PrioritizeLightingQuality = true

    print(game:GetService("Lighting").PrioritizeLightingQuality)

    GameManager.SetGame(game)
end

return Test