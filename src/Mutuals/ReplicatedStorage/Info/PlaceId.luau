local RunService = game:GetService("RunService")

local ExperienceInfo = require("@Info/ExperienceInfo")

local PlaceId = {}

function PlaceId.Get()
    local placeId = game.PlaceId

	if RunService:IsStudio() then
        local currentPlace = ExperienceInfo.CurrentPlace

        placeId = ExperienceInfo.Places[currentPlace].Id
    end

    print("PlaceId: " .. placeId)

    return placeId
end

return PlaceId