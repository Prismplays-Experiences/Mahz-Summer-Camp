local DefaultScreenSize = Vector2.new(1366, 651)
local CurrentScreenHeight = game.Players.LocalPlayer:GetMouse().ViewSizeY

function ScaleStroke(stroke)
	if stroke:GetAttribute("AlreadyScaled") then
		return
	end
	stroke.Thickness = stroke.Thickness * (CurrentScreenHeight / DefaultScreenSize.Y)

	stroke:SetAttribute("AlreadyScaled", true)
end

function SetUpUI(ui)
	local function scaleAll()
		ui.DescendantAdded:Connect(function(v)
			if v:IsA("UIStroke") then
				ScaleStroke(v)
			end
		end)

		for _, v in ui:GetDescendants() do
			if v:IsA("UIStroke") then
				ScaleStroke(v)
			end
		end
	end

	if ui.ResetOnSpawn then
		game.Players.LocalPlayer.CharacterAdded:Connect(scaleAll)
	end

	scaleAll()
end

script.Parent.Parent.ChildAdded:Connect(function(ui)
	if ui:IsA("ScreenGui") then
		SetUpUI(ui)
	end
end)

for _, ui in script.Parent.Parent:GetChildren() do
	if ui:IsA("ScreenGui") then
		SetUpUI(ui)
	end
end
