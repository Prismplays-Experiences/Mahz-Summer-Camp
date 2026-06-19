local Knit = require("@Packages/Knit")

-- local components = script.Parent.Components

-- for _, component in components:GetDescendants() do
-- 	if not component.Name:match("Component") then
-- 		continue
-- 	end

-- 	require(component)
-- end

Knit.AddControllersDeep(script.Parent.Parent:WaitForChild("Controllers"))
Knit.AddControllersDeep(script.Parent)
Knit.Start():catch(warn):await()
shared.KnitStarted = true
