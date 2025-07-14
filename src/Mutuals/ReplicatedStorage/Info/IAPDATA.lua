local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
return {
    Suppliments = {
        WeightGainShield = {
            Cost = 275,
            Duration = 60,
            func = function(Player)
                local SupplimentsService = Knit.GetService('SupplimentsService')
                SupplimentsService:UseSuppliment(Player, game.ServerStorage.Suppliments.WeightGainShield, 60)
            end
        },
        RecoveryBox = {
            Cost = 150,
            Increment = 35,
            func = function(Player)
                local SupplimentsService = Knit.GetService('SupplimentsService')
                SupplimentsService:RecoverHealth(Player, 35)
            end
        },
        DoubleWeightLoss = {
            Cost = 350,
            Duration = 60,
            func = function(Player)
                local SupplimentsService = Knit.GetService('SupplimentsService')
                SupplimentsService:UseSuppliment(Player, game.ServerStorage.Suppliments.DoubleWeightLoss, 60)
            end
        },
    },
    Events = {
    },
}