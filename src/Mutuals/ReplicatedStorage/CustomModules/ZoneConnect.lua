--> Services
----------------------------------------
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--> Packages
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild('Packages')
local ZonePlus = require(Packages:WaitForChild('ZonePlus'))
local Signal = require(Packages:WaitForChild('Signal'))

--> Utility Functions
----------------------------------------

function CreateZone(PART)
	local container = ZonePlus.new(PART)
    return container
end

--> Main Functions
----------------------------------------
local ZoneConnect = {}
ZoneConnect.__index = ZoneConnect

function ZoneConnect:new(Zone,EnterFunction,ExitFunction,MainPlr)
    local instance = setmetatable({}, ZoneConnect)
    instance.Container = CreateZone(Zone)
    instance.EnterFunction = EnterFunction
    instance.ExitFunction = ExitFunction

    instance.Container.playerEntered:Connect(function(player)
        if MainPlr and player ~= MainPlr then return end
        instance.EnterFunction()
    end)
    if instance.ExitFunction then 
    
        instance.Container.playerExited:Connect(function(player)
            if MainPlr and player ~= MainPlr then return end
            instance.ExitFunction()
        end)
    end
  

    return instance
end

function ZoneConnect:Cleanup()
    self.Container:Destroy()
end

return ZoneConnect