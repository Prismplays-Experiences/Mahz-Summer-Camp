local Player = game.Players.LocalPlayer or game.Players:GetPropertyChangedSignal("LocalPlayer")

local Mouse = Player:GetMouse()

local CurrentItems = {}

--Private functions
local function IsInFrame(v)

	local X = Mouse.X
	local Y = Mouse.Y

	if X>v.AbsolutePosition.X and Y>v.AbsolutePosition.Y and X<v.AbsolutePosition.X+v.AbsoluteSize.X and Y<v.AbsolutePosition.Y+v.AbsoluteSize.Y then
		return true
	else 
		return false
	end
end

function IsUIElementVisible(Frame: Instance): boolean
	local screenGui = Frame:FindFirstAncestorWhichIsA("ScreenGui")

	if screenGui and screenGui.Enabled == false then
		return false
	end
	while Frame ~= screenGui or Frame ~= nil do
		if Frame == nil then break end
		if Frame:IsA("GuiObject") and Frame.Visible == false then
			return false
		end

		Frame = Frame.Parent
	end

	return true
end

local function CheckMouseExited(Object)

	if not Object.MouseIsInFrame and Object.MouseWasIn then --Mouse was previously over object, fire leave event
		Object.MouseWasIn = false
		Object.LeaveEvent:Fire()
	end
end


local function CheckMouseEntered(Object)
	if Object.MouseIsInFrame and not Object.MouseWasIn then
		Object.MouseWasIn = true
		Object.EnteredEvent:Fire()
	end
end

game:GetService("RunService").Heartbeat:Connect(function()
	--Check each UI object
	--All exit events fire before all enter events for ease of use, so check for mouse exit events here
	for _, Object in pairs(CurrentItems) do
		Object.MouseIsInFrame = IsInFrame(Object.UIObj)
		if IsUIElementVisible(Object.UIObj) then
			CheckMouseExited(Object)
		end
	end

	--Now check if the mouse entered any frames
	for _, Object in pairs(CurrentItems) do
		if IsUIElementVisible(Object.UIObj) then
			CheckMouseEntered(Object)
		end

	end
end)

--Public functions

local module = {}

function module.MouseEnterLeaveEvent(UIObj)
	if CurrentItems[UIObj] then
		return CurrentItems[UIObj].EnteredEvent.Event,CurrentItems[UIObj].LeaveEvent.Event
	end     

	local newObj = {}

	newObj.UIObj = UIObj

	local EnterEvent = Instance.new("BindableEvent")
	local LeaveEvent = Instance.new("BindableEvent")

	newObj.EnteredEvent = EnterEvent
	newObj.LeaveEvent = LeaveEvent
	newObj.MouseWasIn = false
	CurrentItems[UIObj] = newObj

	UIObj.AncestryChanged:Connect(function()
		if not UIObj.Parent then
		
			EnterEvent:Destroy()    
			LeaveEvent:Destroy()    
			CurrentItems[UIObj] = nil
		end
	end)

	return EnterEvent.Event,LeaveEvent.Event
end

return module