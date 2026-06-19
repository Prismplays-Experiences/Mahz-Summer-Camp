There is Knit singletons' styling guide that you need to apply for every new singleton you create/edit

## Singleton Naming
1. Singletons should be named in PascalCase
2. Name should reflect the purpose of the singleton
3. Singleton name should be the name of the file (But with "..Service" or "..Contoller" suffix if there is none)

### Example:
```lua
-- GOOD
PlayerService, InventoryController, GameManagerService
```

```lua
-- BAD
playerService -- not PascalCase
GameManager -- don't contain "Service" or "Controller" suffix
MyController -- not descriptive enough
```

## Self 
1. Every method in the singleton should use `self` as the first parameter except methods which are not using `self` (like static methods)
2. Because of the first point, every method should be defined by a dot, not by a colon
3. `self` should be typed as the singleton type itself
4. When you call the method and if this method is not static (static = not using self), you should use a colon `:` instead of a dot `.` to call it. If the method not using self, then you should use a dot `.` to call it

### Important Notes About Self For Services
1. In service methods, which are passed to the client, `self` should be typed as the client type of the service, which is `singletonName`..Client

### Example of Singleton:
```lua
-- GOOD
-- here I skipped receiving the Frame cos it's not necessary for this example
-- here I skipped writing the type, but you should write it. More about it in the "Singleton types" section

local PlayerUiController = {}
PlayerUiController.Name = "PlayerUiController"

function PlayerUiController.KnitInit(self: PlayerUiController)
    self._privateVariable = 42

    self:_setUi(self._getStarterUi())
end

function PlayerUiController._getStarterUi()
    return Frame.GameUi
end

function PlayerUiController._setUi(self: PlayerUiController, newUi: Frame)
    self._ui = newUi
end

return PlayerUiController
```

```lua
-- BAD
-- here I skipped receiving the Frame cos it's not necessary for this example
-- here I skipped writing the type, but you should write it. More about it in the "Singleton types" section
local PlayerUiController = {}
PlayerUiController.Name = "PlayerUiController"

function PlayerUiController:KnitInit() -- used a colon instead of a dot, which is incorrect because self is using here
    self._privateVariable = 42

    self._setUi(self, self:_getStarterUi())

    -- instead of callind ._setUi(self, ...) we need to call it using a colon. This is because _setUi is not a static method
    -- we should call _getStarterUi using a dot, because it is a static method
end

function PlayerUiController._getStarterUi()
    return Frame.GameUi
end

function PlayerUiController._setUi(self, newUi: Frame) -- we need to write a type here to self
    self._ui = newUi
end

return PlayerUiController
```

### Examples of services client passed methods:
```lua
-- GOOD
-- here I skipped writing types, but you should write it. More about it in the "Singleton types" section

local PlayerService = {}
PlayerService.Name = "PlayerService"
PlayerService.Client = {}

function PlayerService.KnitInit(self: PlayerService)
    self._playersNumbersPairs = {}
end

function PlayerService.Client.UpdatePlayerNumber(self: PlayerServiceClient, player: Player, newNumber: number)
    self.Server._playersNumbersPairs[player] = newNumber
end
```

```lua
-- BAD
-- here I skipped writing types, but you should write it. More about it in the "Singleton types" section

local PlayerService = {}
PlayerService.Name = "PlayerService"
PlayerService.Client = {}

function PlayerService.KnitInit(self: PlayerService)
    self._playersNumbersPairs = {}
end

function PlayerService.Client.UpdatePlayerNumber(self: PlayerService, player: Player, newNumber: number) -- Bad because self is type of PlayerService, not PlayerServiceClient
    self.Server._playersNumbersPairs[player] = newNumber
end
```

## Singleton types
1. You need to create a type for every singleton and export it
2. This type should be named as the singleton name
3. Every method or property in this exported type should be also typed. This means should also have what parameters it takes and what it returns
4. There should be a Name property in the type, which should be a string
5. This type shouldn't contain KnitInit or KnitStart methods
6. Private variables and methods should be also included in the type
7. Signals should have type of `RBXScriptSignal` without any generics

### Important For Services
1. There should be a Client property in the type, which should be a `singletonName`..Client named type
2. This client type should contain all client-side methods and properties that the service provides to the client
3. This client type should be exported from the service module
4. This client type should contain a Server property, which should reference the service type itself
5. Properties in Client table should have type of table with nothing in it. Without any generics

### Examples of singleton types:
```Luau
-- GOOD

export type DataServiceClient = {
    DataUpdated: RBXConnectionSignal
    Data: {}
}

export type DataService = {

}

local DataService = {}
DataService.Name = "DataService"
DataService.Client = {
    DataUpdated = Knit.CreateSignal(),
    Data = Knit.CreateProperty({}),
}

function DataService.KnitInit(self: DataService)
    self._playersData = {}
end

function DataService.GetPlayerData(self: DataService, player: Player): { [string]: any }
    return self._playersData[player]
end

function DataService.Client.GetPlayerData(self: DataServiceClient, player: Player)
    self.Server._playersData[player] = data
    self.Server.Client.DataUpdated:Fire(player, data)
end

function DataService._updateUi()
   -- some code
end

```

## Private Variables
1. Private variables should be prefixed with an underscore `_`
2. Private variables should be in table of the singleton, not just `local..`

