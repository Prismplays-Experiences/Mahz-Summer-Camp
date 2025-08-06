--> Services
-----------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--> Modules
-----------------------------------------
local Knit = require("@Packages/Knit")

--> Assets
-----------------------------------------
local Assets = ReplicatedStorage:WaitForChild("Assets")
local AuraModels = Assets:WaitForChild("Auras")

--> Knit Setup
-----------------------------------------
local AurasService = Knit.CreateService({
	Name = "AurasService",
	Size = {},
	Client = {},
})

--> Utility Functions
-----------------------------------------

function ClearAuras(Player)
	if not Player or not Player.Character then
		return
	end
	local Character = Player.Character
	local LowerTorso = Character:FindFirstChild("LowerTorso")
	if not LowerTorso then
		return
	end
	for _, Aura in pairs(LowerTorso:GetChildren()) do
		if Aura:HasTag("Aura") then
			Aura:Destroy()
		end
	end
end

--> Main Functions
-----------------------------------------

function AurasService.Client:EquipAura(Player, AuraName)
	if not Player then
		return
	end

	if AuraName == nil or AuraName == "" then
		Player:SetAttribute("EquippedAura", "")
		Player:SetAttribute("AuraRate", 0)
		ClearAuras(Player)
		return
	end
	local AuraTool = Player.Backpack:FindFirstChild(AuraName) or Player.Character:FindFirstChild(AuraName)
	if not AuraTool then
		return
	end
	Player:SetAttribute("AuraRate", AuraTool:GetAttribute("AuraRate") or 0.1)
	Player:SetAttribute("EquippedAura", AuraName)
	if Player:GetAttribute("WorkoutStatus") then
		self:GiveAura(Player, AuraName)
	end
end

function AurasService.Client:GiveAura(Player)
	local AuraName = Player:GetAttribute("EquippedAura")
	if not Player or not AuraName then
		return
	end
	local AuraTool = Player.Backpack:FindFirstChild(AuraName) or Player.Character:FindFirstChild(AuraName)
	if not AuraTool then
		return
	end

	local AuraModel = AuraModels:FindFirstChild(AuraName)
	if not AuraModel then
		return
	end

	local LowerTorso = Player.Character.LowerTorso
	if not LowerTorso then
		return
	end
	ClearAuras(Player)

	local Aura = AuraModel:Clone()

	for _, particle in Aura:GetDescendants() do
		particle:AddTag("Aura")
		particle:SetAttribute("BaseRate", particle.Rate)
		self.Server.Size[particle] = particle.Size.Keypoints
		particle.Parent = LowerTorso
	end
	Aura:Destroy()
end

function AurasService.Client:RemoveAura(Player)
	if not Player then
		return
	end

	ClearAuras(Player)
end

function AurasService.Client:AdjustAuraRate(Player, Rate)
	if not Player or not Player.Character then
		return
	end
	if not Player:GetAttribute("EquippedAura") then
		return
	end

	local Auras = {}

	for _, aura in pairs(Player.Character.LowerTorso:GetChildren()) do
		if aura:HasTag("Aura") then
			table.insert(Auras, aura)
		end
	end
	local AuraTool = Player.Backpack:FindFirstChild(Player:GetAttribute("EquippedAura"))
		or Player.Character:FindFirstChild(Player:GetAttribute("EquippedAura"))

	for i, descendant in ipairs(Auras) do
		Rate = math.clamp(Rate, AuraTool:GetAttribute("MinRate"), AuraTool:GetAttribute("MaxRate"))
		if descendant:IsA("ParticleEmitter") then
			-- Multiply Rate
			local applyrate = math.clamp(descendant.Rate * Rate, descendant:GetAttribute("BaseRate"), math.huge)
			descendant.Rate = applyrate

			-- Multiply Size (NumberSequence)
			-- Store original size at some earlier point:
			-- self.Size[particle] = particle.Size.Keypoints

			local originalSize = descendant.Size
			local storedSize = self.Server.Size[descendant]
			if not storedSize then
				return
			end -- safety check

			local newKeypoints = {}

			for _, keypoint in ipairs(originalSize.Keypoints) do
				local baseKeypoint = storedSize[i]
				if baseKeypoint then
					table.insert(
						newKeypoints,
						NumberSequenceKeypoint.new(
							keypoint.Time,
							math.clamp(keypoint.Value * Rate, baseKeypoint.Value, math.huge),
							math.clamp(keypoint.Envelope * Rate, baseKeypoint.Envelope, math.huge)
						)
					)
				end
			end

			descendant.Size = NumberSequence.new(newKeypoints)
		end
	end
end

-----------------------------------------

return AurasService
