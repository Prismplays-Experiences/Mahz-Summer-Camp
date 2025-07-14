local GuiContents = {}
local Modules = script.Parent
local MouseMovement = require(Modules:WaitForChild('MouseRegister'))
local RadialGrow = require(Modules:WaitForChild('RadialGrow'))

local Debounce = Instance.new('BoolValue')
Debounce.Name = 'Debounce'
Debounce.Parent = script

local mouse = game.Players.LocalPlayer:GetMouse()

local TweenService = game:GetService('TweenService')
local UserInputService = game:GetService('UserInputService')

function getplatform()
	if UserInputService.TouchEnabled then
		return "Mobile"
	elseif UserInputService.KeyboardEnabled then
		return "Pc"
	end
end

local Platform = getplatform()

function GetUIScale(UI)
	for _,props in pairs (UI:GetChildren()) do
		if props:IsA('UIScale') then
			return props
		end
	end
	return nil
end

GuiContents['ClearChildren'] = function(UI)
	for _,v in pairs(UI:GetChildren()) do
		if v:IsA('GuiObject') then
			v:Destroy()
		end
	end
end

GuiContents['MouseMovement'] = function(Sound,UI,Hover,Increase,Decrease,_,SoundEffects)
	-- if SoundEffects == nil then SoundEffects = script end
	if not UI:IsA('GuiObject') then return end
	local UIScale = GetUIScale(UI)
	if UIScale == nil then
		UIScale = Instance.new('UIScale')
        UIScale.Parent = UI
	end
	
	if not UI:IsA('GuiButton') then
		return
	end
	
	local DefaultScaleValue = UIScale.Scale
	
	local UIScaleType = {}
	if Increase~= nil then
		UIScaleType.mouse_Enter = TweenService:Create(UIScale,TweenInfo.new(0.07),{Scale = Increase});
		UIScaleType.mouse_Leave = TweenService:Create(UIScale,TweenInfo.new(0.1),{Scale = DefaultScaleValue});
	elseif Decrease~= nil then
		UIScaleType.mouse_Enter = TweenService:Create(UIScale,TweenInfo.new(0.07),{Scale = Decrease});
		UIScaleType.mouse_Leave = TweenService:Create(UIScale,TweenInfo.new(0.1),{Scale = DefaultScaleValue});
	else
		UIScaleType = nil
	end
	

	local DefaultScale = {
		mouse_Enter = TweenService:Create(UIScale,TweenInfo.new(0.07),{Scale = 1.05});
		mouse_Leave = TweenService:Create(UIScale,TweenInfo.new(0.1),{Scale = DefaultScaleValue});
	}
	
	if Hover then
		
		local MouseEnter,MouseLeave = MouseMovement.MouseEnterLeaveEvent(UI)
		
		local function CheckDisconnect()
			if UI == nil then
				MouseEnter:Disconnect()
				MouseLeave:Disconnect()
			end
		end
		
		MouseEnter:Connect(function()
			CheckDisconnect()
			if Platform == 'Pc' then
				if Sound then
					task.spawn(function()
						if script.Debounce.Value then return end
						script.Debounce.Value = true
						SoundEffects:WaitForChild('Hover'):Play()
						wait(0.2)
						script.Debounce.Value = false
					end)
					
				end
			end
			if UIScaleType == nil then
					DefaultScale.mouse_Enter:Play()
				return
			end
				UIScaleType.mouse_Enter:Play()
			
			
		end)
		MouseLeave:Connect(function()
			CheckDisconnect()
			if UIScaleType == nil then
					DefaultScale.mouse_Leave:Play()
				
				return
			end
				UIScaleType.mouse_Leave:Play()
			
		end)
	else
		local Button1Down,Button1Up = UI.MouseButton1Down, UI.MouseButton1Up
		local function CheckDisconnect()
			if UI == nil then
				Button1Down:Disconnect()
				Button1Up:Disconnect()
			end
		end
		Button1Down:Connect(function()
			CheckDisconnect()
			if UIScaleType == nil then
					DefaultScale.mouse_Enter:Play()
				return
			end
				UIScaleType.mouse_Enter:Play()
		end)
		Button1Up:Connect(function()
			CheckDisconnect()
			if Platform == 'Pc' then
				if Sound then
					SoundEffects:WaitForChild('PcToogle'):Play()
				end
			else
				if Sound then
					SoundEffects:WaitForChild('MobileToogle'):Play()
				end
			end
			if UIScaleType == nil then
					DefaultScale.mouse_Leave:Play()
				return
			end
				UIScaleType.mouse_Leave:Play()
		end)
	end
end

GuiContents['Radial'] = function(Guibtn,_,clipdescendants)
	
	Guibtn.MouseButton1Click:Connect(function()
		RadialGrow(Guibtn,clipdescendants)
	end)
	
end

function GuiContents.clickEffect(particleImage,parent,mousex,mousey)
	local count = 7
	local mouseX = mousex or mouse.X
	local mouseY = mousey or mouse.Y
	task.wait()
	for _=0,count,1 do
		spawn(function()
			
			local particle = Instance.new("ImageLabel")
			particle.Image = particleImage
			particle.BackgroundTransparency = 1
			particle.Parent = parent
			particle.Position = UDim2.new(0,mouseX,0,mouseY)
			--particle.AnchorPoint = parent.AnchorPoint
			local size = math.random(9,18)
			particle.Size = UDim2.new(0,size,0,size)
			particle.ZIndex = 150

			local goal = {}
			goal.Position = UDim2.new(0,particle.Position.X.Offset+(math.random(-50,50)),0,particle.Position.Y.Offset+(math.random(-50,50)))
			goal.Transparency = 1
			local transtween = TweenService:Create(particle,TweenInfo.new(0.5),{ImageTransparency=1})
			local info = TweenInfo.new(1.5,Enum.EasingStyle.Quart)
			local tween = TweenService:Create(particle,info,goal)
			tween:Play()
			wait(0.5)
			transtween:Play()
			tween.Completed:Connect(function()
				particle:Remove()
			end)
		end)
	end

end

return GuiContents
