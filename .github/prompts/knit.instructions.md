# Knit core basis
Knit is a Luau framework which designed exclusively for Roblox game development

# Core concepts
## Singletons
Singletons are ModuleScripts that are returning tables which are just tables with methods and properties (.Name property is requireed)

Knit organizes code by 2 main types of singletons:
- Services: Server-sided singletons which are used to manage game logic
- Controllers: Client-sided singletons which are used to manage user interface and client-side logic

## Lifecycle Events
Knit provides lifecycle events that are easy to implement and use:
- `KnitStart()`: Executed after injection when the singleton is ready. In this phase you can work with other singletons and call their methods/events
- `KnitInit()`: Executed before calling other singletons; used for initialization. In this phase you shouldn't call methods or work with other singletons (you can only require)

### Example:
```lua
-- GOOD
local OtherService = require("@Services/OtherService")

local MyService = {}
MyService.Name = "MyService"
MyService.Client = {}

function MyService:KnitInit()
    print("MyService is initializing")
end

function MyService:KnitStart()
    OtherService:SomeMethod() -- Call method from OtherService
    print("MyService has started")
end

return MyService
```
```lua
-- BAD
local OtherService = require("@Services/OtherService")

local MyService = {}
MyService.Name = "MyService"
-- There is no Client table here, this will cause an error

function MyService:KnitInit()
    OtherService:SomeMethod() -- This is bad, because OtherService may not be initialized yet
    print("MyService is initializing")
end

function MyService:KnitStart()
    print("MyService has started")
end

return MyService
```

## Calling Other singletons
To call other singletons, you need just require them

### Example:
```lua
-- On server-side
local MyService = require("@Services/MyService")

MyService:MyMethod() -- Call method from MyService
```
```lua
-- On client-side
local MyController = require("@Controllers/MyController")

MyController:MyMethod() -- Call method from MyController
```

## Services
Services are server-sided singletons which are used to manage game logic. Example of service:
```lua
--GOOD

local Knit = require("@Packages/Knit")

local OtherService = require("@Services/OtherService")

local MyService = {}
MyService.Name = "MyService"
MyService.Client = {
    -- Client methods/signals/properties can be defined here
    SomeSignal = Knit.CreateSignal()
    SomeProperty = Knit.CreateProperty("InitialValue")
}
MyService.lol = 3

function MyService:KnitInit()
    print("MyService is initializing")
end

function MyService:KnitStart()
    OtherService:SomeMethod() -- Call method from OtherService
    print("MyService has started")
end

-- You can add this above, when defining Client table, but better practice is to define it like below
function MyService.Client:SomeMethod()
    print(self.Server.lol) -- Access server-side property via .Server

    self.Server.Client.SomeSignal:Fire("Hello from MyService.Client") -- Fire client-side signal
    self.Server.Client.SomeProperty:Set("NewValue") -- Set client-side property
end

return MyService
```

```lua
--BAD EXAMPLE 1

local Knit = require("@Packages/Knit")

local OtherService = require("@Services/OtherService")

local MyService = {}
MyService.Name = "MyService"
-- missing Client table, this will cause an error
MyService.lol = 3

function MyService:KnitInit()
    OtherService:SomeMethod() -- Methods of other singletons should be called in KnitStart or in functions that are called in KnitStart. Or in methods that you know will be called after service started
    -- This is bad, because OtherService may not be initialized yet
    print("MyService is initializing")
end

function MyService:KnitStart()
    print("MyService has started")
end

return MyService
```

```lua
--BAD EXAMPLE 2

local Knit = require("@Packages/Knit")

local MyService = {}
MyService.Name = "MyService"
MyService.Client = {}
MyService.lol = 3

function MyService:KnitInit()
    print("MyService is initializing")
end

function MyService:KnitStart()
    print("MyService has started")
end

-- You can add this above, when defining Client table, but better practice is to define it like below
function MyService.Client:SomeMethod()
    print(self.lol) -- This will cause an error, because self is Client table, not Server table. To access .lol you need to write something like `self.Server.lol`
end

return MyService
```

### Important notes:
- Always define `.Client` table, even if you don't need it. This is required for Knit to work properly.
- Always call methods of other singletons in `KnitStart` or in functions that are called in `KnitStart`. This is to ensure that the other singleton is initialized and ready to be used. Also you can call methods of other singletons but only if you 100% sure that service is started and ready to be used (for example, if you know that this method will be called after `KnitStart`).
- Signals and properties that should be passed to Client should be created using `Knit.CreateSignal()` and `Knit.CreateProperty()`, respectively. This ensures that they are properly initialized and can be used on the client-side.
- You can access server-side properties and methods from the client-side using `self.Server` in the Client table. This is useful for accessing server-side logic from the client.
- There is no way to call controllers' methods from services. Only in one way (controllers can call services' methods)

## Controllers
Controllers are client-sided singletons which are used to manage user interface and client-side logic. Example of controller:
```lua
-- GOOD

local Knit = require("@Packages/Knit")

local OtherController = require("@Controllers/OtherController")

local MyController = {}
MyController.Name = "MyController"

function MyController:KnitInit()
    -- You need to require services only via Knit, not via require
    -- You can call and use methods of services in controller EVEN IN INIT PHASE, but you should not call methods of other controllers in this phase. This is because services are initialized before controllers, so you can be sure that service is ready to be used
    local MyService = Knit.GetService("MyService") -- Get service instance

    MyService.SomeSignal:Connect(function(data)
        print("Received signal from MyService.Client:", data) -- Handle signal from MyService.Client
    end)

    MyService.SomeProperty:Observe(function(newValue)
        print("MyService.Client.SomeProperty changed to:", newValue) -- Handle property change from MyService.Client
    end)

    MyService:SomeMethod() -- Call method from MyService

    print("MyController is initializing")
end

function MyController:KnitStart()
    OtherController:SomeMethod() -- Call method from OtherController

    print("MyController has started")
end

return MyController
```
```lua
-- BAD
local MyService = require("@Services/MyService") -- This is bad, because services should be required via Knit.GetService() method, not via require
local OtherController = require("@Controllers/OtherController")

local MyController = {}
MyController.Name = "MyController"

function MyController:KnitInit()
    -- Everything below (except of print) won't work because MyService required wrong

    MyService.SomeSignal:Connect(function(data)
        print("Received signal from MyService.Client:", data) -- Handle signal from MyService.Client
    end)

    MyService.SomeProperty:Observe(function(newValue)
        print("MyService.Client.SomeProperty changed to:", newValue) -- Handle property change from MyService.Client
    end)

    MyService:SomeMethod() -- Call method from MyService

    print("MyController is initializing")
end

function MyController:KnitStart()
    OtherController:SomeMethod() -- Call method from OtherController

    print("MyController has started")
end

return MyController
```

### Important notes:
- Always define `.Name` property, this is required for Knit to work properly.
- Always call methods of other controllers in `KnitStart` or in functions that are called in `KnitStart`. This is to ensure that the other controller is initialized and ready to be used. Also you can call methods of other controllers but only if you 100% sure that controller is started and ready to be used (for example, if you know that this method will be called after `KnitStart`).
- Services should be required via `Knit.GetService("ServiceName")` method, not via `require`
- You can access services in any time you want, even in `KnitInit` phase. This is because services are initialized before controllers, so you can be sure that service is ready to be used.

## Benefits of using Knit
- **Modularity**: Knit encourages modular code structure, making it easier to manage and maintain large codebases.
- **Lifecycle Management**: The lifecycle events (`KnitInit`, `KnitStart`) provide a clear structure for initialization and startup, ensuring that dependencies are ready when needed.
- **Client-Server Communication**: The framework simplifies communication between client and server through signals/properties/methods, allowing for efficient data handling and event-driven programming.
- **Minimizing**: Minimizes boilerplate code
