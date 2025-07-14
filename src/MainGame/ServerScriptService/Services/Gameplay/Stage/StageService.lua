--> Services
----------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService('ServerStorage')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService("RunService")

--> Modules
----------------------------------------
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Signal = require(Packages:WaitForChild("Signal"))
local Knit = require(Packages:WaitForChild("Knit"))
local GeneralInfo = require(ReplicatedStorage:WaitForChild('Info'):WaitForChild("GeneralInfo"))

--> Assets
----------------------------------------
local ScriptingProperties = workspace.Game.ScriptingProperties
local StagePropsHolder = ScriptingProperties.StagePropsHolder
local CenterCam = StagePropsHolder:WaitForChild('CenterCam')
local StageProps = ServerStorage:WaitForChild('Assets'):WaitForChild('StageProps')
local SpawnPoints = StagePropsHolder:WaitForChild('SpawnPoints')

local Models = ReplicatedStorage:WaitForChild('Models')
local ScaleWeight = Models:WaitForChild('ScaleWeight')
local SoundEffects = Models:WaitForChild('SoundEffects')

local Assets = ServerStorage.Assets

--> Variables
----------------------------------------
local CurrentStageItem = nil
function SetStage(ItemName)
    if CurrentStageItem then CurrentStageItem:Destroy() end
    CurrentStageItem = StageProps[ItemName]:Clone()
    CurrentStageItem.Parent = StagePropsHolder
    return CurrentStageItem:FindFirstChild('WalkPoints')
end



--> Knit Setup
----------------------------------------
local StageService = Knit.CreateService {
    Name = "StageService",
    StageEventRunning = false,
    Client = {
        StageCameraView = Knit.CreateUnreliableSignal(),
        PlayerCameraTrack = Knit.CreateUnreliableSignal(),
        EliminatedStageEffect = Knit.CreateUnreliableSignal(),
        PassedStageEffect = Knit.CreateUnreliableSignal(),
        WinnersStageEffect = Knit.CreateUnreliableSignal(),
        SetCamStatus = Knit.CreateUnreliableSignal(),
    }
}

--> Utility Functions
----------------------------------------

function DeepCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            value = DeepCopy(value)
        end
        copy[key] = value
    end
    return copy
end

function StageService:WalkToStage(Players, Camera, AmountPerSegment, WalkPoints, MultipleOnStage, func, sp)
    self.GeneralGameplay.Client.DisableControls:FireAll()

    local NewSpawnPoints = SpawnPoints:GetChildren()
    local queue = {}

    for i, Player in ipairs(Players) do
        if not Player then continue end

        table.insert(queue, Player)

        if #queue >= AmountPerSegment or i == #Players then
            -- Process batch
            local NewWalkPoints = DeepCopy(WalkPoints)
            for j, plr in ipairs(queue) do
                local Character = plr.Character
                if not Character then continue end

                local SpawnPoint = sp or NewSpawnPoints[math.random(1, #NewSpawnPoints)]
                local WalkPoint = NewWalkPoints[1]
                table.remove(NewWalkPoints, 1)

                PivotToSpot(Character, SpawnPoint)
                print(Character)
                local walkFn = function()
                    WalktoSpot(Character, {WalkPoint}, true)
                end
                task.spawn(walkFn)
                -- if MultipleOnStage or not Camera then
                --     task.spawn(walkFn)
                -- else
                    -- walkFN()
                -- end

                if Camera and #queue < 2 then
                    print('fired')
                    self.Client.PlayerCameraTrack:FireAll(true, Character, WalkPoint, SpawnPoint)
                    task.wait(4)
                end

                if func and not MultipleOnStage then
                    -- local s,e = pcall(function()
                        
                    -- end)
                    func(self, plr)
                end
            end

            table.clear(queue)
        end
    end
end




function PlaySoundOnRemove(Sound)
    local nsound = Sound:Clone()
    nsound.PlayOnRemove = true
    nsound.Parent = CenterCam
    nsound:Destroy()
end



function TweenNumberOnLabel(label: TextLabel, targetValue: number, duration: number, suffix: string?,halt,Sound)
	suffix = suffix or ""

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = tonumber(label.Text:match("%d+")) or 0

	local tween = TweenService:Create(
		numberValue,
		TweenInfo.new(duration or 1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
		{Value = targetValue}
	)

	local connection
	connection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
        if Sound then PlaySoundOnRemove(Sound) end
		label.Text = string.format("%d%s", math.floor(numberValue.Value), suffix)
	end)

	tween:Play()

	tween.Completed:Once(function()
		label.Text = string.format("%d%s", targetValue, suffix)
		if connection then connection:Disconnect() end
        connection = nil
		numberValue:Destroy()
	end)
    if halt then
        repeat task.wait(0.1) until not connection
    end
end


function PivotToSpot(Character,target)
    Character:PivotTo(target.CFrame * CFrame.new(0, 3, 0))
end

function WalktoSpot(Character,target, PivotAfter)
		
	-- StopAllAnimations(p)
    for i = 1,#target do
        while task.wait(0.1) do
            local Humanoid:Humanoid = Character.Humanoid
            Humanoid.WalkSpeed = 16
            Humanoid:MoveTo(target[i].Position)
            Humanoid.MoveToFinished:Wait()
            -- Humanoid.WalkSpeed = 0
            if (Character.HumanoidRootPart.Position - target[i].Position).Magnitude < 5 then
                break
            end
        end
    end
    if PivotAfter then
        PivotToSpot(Character, target[#target])
    end
end

--> Main Functions
----------------------------------------
function StageService:KnitStart()
    self.GeneralGameplay = Knit.GetService('GeneralGameplay')
    self.TargetService = Knit.GetService('TargetService')
    self.LifeService = Knit.GetService('LifeService')
    self.TransitionService = Knit.GetService('TransitionService')
    self.MusicService = Knit.GetService('MusicService')
end

function StageService:EnableControls()
    for i,plr in game.Players:GetPlayers() do
        self.GeneralGameplay.Client.EnableControls:FireAll()
    end
end

function StageService:WaitTillReady()
    repeat task.wait() until self.StageEventRunning == false
    self.StageEventRunning = true
end

function StageService:Winners(TransitionScreen)
    self.MusicService:NewSong('StageEvents')
    self:WaitTillReady()
    local End
    if TransitionScreen then
        End = self.TransitionService:SendTransitionAll('Winners!!')
        task.wait(2)
    end
    local WalkPoints = SetStage('Winners'):GetChildren()
    local Winners = self.GeneralGameplay:GetWinners()
    for i,p in Winners do
        task.spawn(function()
            p.leaderstats.Wins.Value += 1
        end)
    end
    self.Client.SetCamStatus:FireAll('Default',CenterCam)
    task.wait(2)
    End:FireAll()
    self:WalkToStage(Winners,true, 1, WalkPoints, true)
    -- task.wait(2)
    self.Client.WinnersStageEffect:FireAll(Winners)
    task.wait(6)
    local End = self.TransitionService:SendTransitionAll()
    task.wait(2)
    self.Client.PlayerCameraTrack:FireAll(false)
    self:EnableControls()
    CurrentStageItem:Destroy()
    task.wait(2)
    End:FireAll()
    self.StageEventRunning = false
    self.MusicService:NewSong('Default')
end

function StageService:Eliminated(TransitionScreen,EndTransition,func)
    self.MusicService:NewSong('StageEvents')
    self:WaitTillReady()
    local End
    if TransitionScreen then
        End = self.TransitionService:SendTransitionAll('A player has been Eliminated.')
        task.wait(2)
    end
    local WalkPoints = SetStage('Eliminated'):GetChildren()
    local Losers = self.LifeService:GetEliminated()
    for i,p in Losers do
        task.spawn(function()
            p.leaderstats:WaitForChild('Lifes').Value = 0
        end)
    end
    self.Client.SetCamStatus:FireAll('Default',CenterCam)
    task.wait(2)
    End:FireAll()
    self:WalkToStage(Losers,true, 2, WalkPoints, true)
    -- task.wait(2)
    self.Client.EliminatedStageEffect:FireAll(Losers)
    task.wait(6)
    local End
    if EndTransition then
        End = self.TransitionService:SendTransitionAll()
    end
    if func then
        task.spawn(function()
            func()
        end)

    end
    task.wait(2)
    self.Client.PlayerCameraTrack:FireAll(false)
    self:EnableControls()
    self.Client.SetCamStatus:FireAll('cleanup')
    CurrentStageItem:Destroy()
    task.wait(2)
    if EndTransition then
        End:FireAll()
    end
    self.StageEventRunning = false
    self.MusicService:NewSong('Default')
end

-- function StageService:Passed()
--     self:WaitTillReady()
--     local WalkPoints = SetStage('Passed')
--     local Winners = self.GeneralGameplay:GetWinners()
--     self:WalkToStage(Winners,true, 2, WalkPoints, true)
--     self.Client.PassedStageEffect:FireAll(Winners)
--     task.wait(15)
--     self.Client.PlayerCameraTrack:FireAll(false)
--     self.StageEventRunning = false
-- end

function StageService:WeightPlayers(TransitionScreen, EndTransition, func)
    self:WaitTillReady()
    local End
    if TransitionScreen then
        End = self.TransitionService:SendTransitionAll('Weighting Time!', 'Day over.')
        task.wait(3)
    end
    local WalkPoints = SetStage('ScalingStage'):GetChildren()
    local Players = self.GeneralGameplay:GetWinners()
    self.Client.SetCamStatus:FireAll('Default',CenterCam)
    task.wait(2)
    End:FireAll()
    self:WalkToStage(Players,true, 1, WalkPoints, false, self.WeightingScale,SpawnPoints['2'])
    local End
    if EndTransition then
        End = self.TransitionService:SendTransitionAll()
    end
    if func then
        task.spawn(function()
            func()
        end)

    end

    self.Client.PlayerCameraTrack:FireAll(false)
    self.Client.SetCamStatus:FireAll('cleanup')
    task.wait(2)
    self:EnableControls()
    CurrentStageItem:Destroy()
    if EndTransition then
        task.wait(1.5)
        End:FireAll()
    end
    task.wait(0.5)
    self.StageEventRunning = false
end

function StageService.WeightingScale(self,Player)

    local BeforeWeight = Player:GetAttribute('BeforeWeight') or GeneralInfo.Weight
    local CurrentWeight = Player.leaderstats.Weight.Value
    local TargetWeight = self.TargetService:GetTarget()

    local ScriptItems = CurrentStageItem:FindFirstChild('ScriptItems')
    local SurfaceUIS = ScriptItems:FindFirstChild('Screens')
    local BeforeScreen = SurfaceUIS:FindFirstChild('Before')
    local AfterScreen = SurfaceUIS:FindFirstChild('After')

    local Character = Player.Character
    pcall(function()
        Character.PlayerDetails.Enabled = false
        Character.HumanoidRootPart.InfluencerLogos.Enabled = false
    end)

    local CamParts = ScriptItems:FindFirstChild('Cameras')

    self.Client.SetCamStatus:FireAll('Default',CamParts.ScaleView)
    task.wait(2)
    self.Client.SetCamStatus:FireAll('Before', CamParts.Before)
    task.wait(2)
    TweenNumberOnLabel(BeforeScreen.Weight, BeforeWeight, 4, 'lbs',true)
    task.wait(2)
    self.Client.SetCamStatus:FireAll('Default',CamParts.ScaleView)
    task.wait(3)
    self.Client.SetCamStatus:FireAll('FOVIncrease')
    local NewWeight = ScaleWeight:Clone()
    NewWeight.TextLabel.Text = 'N/A'
    NewWeight.Enabled = true
    NewWeight.Parent = Character
    TweenNumberOnLabel(NewWeight.TextLabel, CurrentWeight, 7, ' lbs',true,SoundEffects.Tick)
    self.Client.SetCamStatus:FireAll('FOVDecrease')
    task.wait(1)
    self.Client.SetCamStatus:FireAll('After',CamParts.After)
    task.wait(2)
    TweenNumberOnLabel(AfterScreen.Weight, CurrentWeight, 4, 'lbs',false)
    TweenNumberOnLabel(AfterScreen.TargetWeight, TargetWeight, 4, 'lbs',true)
    task.wait(2)
    self.Client.SetCamStatus:FireAll('Default',CamParts.ScaleView)
    task.wait(1)
    if CurrentWeight <= TargetWeight then
        SoundEffects.HappyCrowd:Play()
        Effects.Passed(Player.Character)
    else
        Effects.Failed(Player.Character)
        if Player.leaderstats.Lifes.Value>1 then
            Player.leaderstats.Lifes.Value -= 1
        else
            Player:AddTag('Eliminated')
        end
        -- if player life above 1 take 1 life, if not add to array of list to eliminate and eliminate after
        -- 
    end

    Player:SetAttribute('BeforeWeight', CurrentWeight)
    task.wait(3)
    local SpawnPoint = SpawnPoints['1']
    task.spawn(function()
        WalktoSpot(Player.Character,{SpawnPoint}, true)
    end)

    task.wait(2)
    NewWeight:Destroy()
    SoundEffects.HappyCrowd:Stop()
    pcall(function()
        Character.PlayerDetails.Enabled = true
        Character.HumanoidRootPart.InfluencerLogos.Enabled = true
    end)
    AfterScreen.Weight.Text = 'N/A'
    AfterScreen.TargetWeight.Text = 'N/A'
    BeforeScreen.Weight.Text = 'N/A'
end

--> More Utility Functions
----------------------------------------

local StageEffect = StagePropsHolder:WaitForChild('StageEffect')
local TweenedItems = StageEffect:WaitForChild('TweenedItems')
local Light = TweenedItems:WaitForChild("SurfaceLight")
local GoodEffect = TweenedItems:WaitForChild("Good")
local BadEffect = TweenedItems:WaitForChild("Bad")
local ScaleStatus = Assets:WaitForChild('ScaleStatus')

Effects = {}
function Effects.Passed(character)
    local newscalestatus = ScaleStatus:Clone()
    local uiscale = newscalestatus.ImageLabel.UIScale
    newscalestatus.Parent = character
    newscalestatus.ImageLabel.TextLabel.Text = 'Passed'
    newscalestatus.ImageLabel.Image = 'rbxassetid://85112731827477'
    TweenService:Create(uiscale,TweenInfo.new(1,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out),{Scale = 1}):Play()
	
	local info = TweenInfo.new(2,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out)
	Light.Color = Color3.fromRGB(0, 255, 0)
	local Tween = TweenService:Create(Light,info,{Brightness = 9})

	Tween:Play()
	task.delay(0.1,function ()
		SoundEffects.Correct:Play()
		GoodEffect:Emit(35)
	end)
	task.delay(0.5,function()
		TweenService:Create(Light,info,{Brightness = 0}):Play()
        task.wait(1)
        newscalestatus:Destroy()
	end)
end

function Effects.Failed(character)
	local newscalestatus = ScaleStatus:Clone()
    local uiscale = newscalestatus.ImageLabel.UIScale
    newscalestatus.Parent = character
    newscalestatus.ImageLabel.TextLabel.Text = 'Failed'
    newscalestatus.ImageLabel.Image = 'rbxassetid://131083473913572'
    TweenService:Create(uiscale,TweenInfo.new(1,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out),{Scale = 1}):Play()

	local info = TweenInfo.new(2,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out)
	Light.Color = Color3.fromRGB(255, 0, 0)
	local Tween = TweenService:Create(Light,info,{Brightness = 9})

	Tween:Play()
	task.delay(0.1,function ()
		SoundEffects.Error:Play()
		BadEffect:Emit(35)
	end)
	task.delay(0.5,function()
		TweenService:Create(Light,info,{Brightness = 0}):Play()
        task.wait(1)
        newscalestatus:Destroy()
	end)
	
end

return StageService