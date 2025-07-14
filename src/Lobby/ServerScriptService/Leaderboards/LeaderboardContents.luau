--> Services
----------------------------------------
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--> Modules
----------------------------------------
local Modules = ReplicatedStorage.Modules
local Utils = Modules.Utils
local TFM = require(Utils:WaitForChild("TFM"))
local ScrollingFrameAutoScale = require(Utils.ScrollingFrameAutoScale)

--> Assets
----------------------------------------
local Assets = ReplicatedStorage.Assets
local LeaderboardAssets = Assets.LeaderboardAssets
local PositionTemplates = {
	First = LeaderboardAssets:WaitForChild("First"),
	Second = LeaderboardAssets:WaitForChild("Second"),
	Third = LeaderboardAssets:WaitForChild("Third"),
	Others = LeaderboardAssets:WaitForChild("Others"),
}

--> Variables
----------------------------------------
MaxAvaters = 3
local Leaderboards = {
	WinsLb = "Wins",
	LosesLb = "Loses",
	DonateLb = "Donate",
	-- ElimsLb = "Elims",
}

local LbData = {}
local Suffixes = {
	"",
	"K",
	"M",
	"B",
	"T",
	"qd",
	"Qn",
	"sx",
	"Sp",
	"O",
	"N",
	"de",
	"Ud",
	"DD",
	"tdD",
	"qdD",
	"QnD",
	"sxD",
	"SpD",
	"OcD",
	"NvD",
	"Vgn",
	"UVg",
	"DVg",
	"TVg",
	"qtV",
	"QnV",
	"SeV",
	"SPG",
	"OVG",
	"NVG",
	"TGN",
	"UTG",
	"DTG",
	"tsTG",
	"qtTG",
	"QnTG",
	"ssTG",
	"SpTG",
	"OcTG",
	"NoAG",
	"UnAG",
	"DuAG",
	"TeAG",
	"QdAG",
	"QnAG",
	"SxAG",
	"SpAG",
	"OcAG",
	"NvAG",
	"CT",
}

--> References
----------------------------------------
--[[
    -- Used to manage and display leaderboard UI templates for specific stats, i.e Wins/Elims
]]

--> Utility Functions
----------------------------------------
local function formatNumber(val)
	for i = 1, #Suffixes do
		if tonumber(val) < 10 ^ (i * 3) then
			return math.floor(val / ((10 ^ ((i - 1) * 3)) / 100)) / 100 .. Suffixes[i]
		end
	end
end

local function getNameFromUserId(userId)
	local success, result = pcall(function()
		return Players:GetNameFromUserIdAsync(userId)
	end)
	return success and result or nil
end

local function getPlayerThumbnail(userId, thumbnailType, thumbnailSize)
	local thumbnail, isReady = Players:GetUserThumbnailAsync(userId, thumbnailType, thumbnailSize)
	return isReady and thumbnail or "rbxassetid://7313814914"
end

local function TweenGroupTransparency(parent, transparency, duration)
	-- Tween CanvasGroup if present for overall transparency
	local canvasGroup = parent:FindFirstChildWhichIsA("CanvasGroup")
	if canvasGroup then
		TweenService:Create(canvasGroup, TweenInfo.new(duration), { GroupTransparency = transparency }):Play()
	end

	-- for _, obj in ipairs(parent:GetDescendants()) do
	-- 	local prop
	-- 	if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
	-- 		prop = "ImageTransparency"
	-- 	elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
	-- 		prop = "TextTransparency"
	-- 	elseif obj:IsA("Frame") then
	-- 		prop = "BackgroundTransparency"
	-- 	end

	-- 	if prop then
	-- 		TweenService:Create(obj, TweenInfo.new(duration), { [prop] = transparency }):Play()
	-- 	end
	-- end
end

--> Main Functions
----------------------------------------
local function FillTemplate(template, data, index, statType)
	template.Name = data.key
	template.LayoutOrder = index
	template.PlayerName.Text = getNameFromUserId(data.key)
	template.PlayerRank.Text = "#" .. index

	local valueText = statType == "TimePlayed" and TFM:Convert(tonumber(data.value), "short")
		or (statType == "MoneyStolen" and formatNumber(data.value))
		or data.value
	template.PlayerValue.Text = valueText

	for _, child in ipairs(template:GetChildren()) do
		if child.Name == "PlayerAvatar" then
			child.Image =
				getPlayerThumbnail(data.key, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size180x180)
		elseif child.Name == "PlayerHeadShot" then
			child.Image = getPlayerThumbnail(data.key, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
		end
	end
end

local function AddToSpot(data,rank, leaderboardGui)
	if not rank then return end
	local Characters = leaderboardGui.Parent:WaitForChild('Characters')
	local charModel = Characters[rank]
	if not charModel then
		return
	end

	task.spawn(function()
		local description = Players:GetHumanoidDescriptionFromUserId(data.key)
		local humanoid = charModel:FindFirstChildOfClass("Humanoid")
		local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
		local tags = charModel:FindFirstChild("Tags")
		local emotes = charModel.Parent:FindFirstChild("CharacterModelEmotes")
		local charscale = charModel:GetScale()
		if tags then
			tags.Enabled = true
			tags.Container.pName.Text = getNameFromUserId(data.key)
		end

		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			track:Stop()
			track:Destroy()
		end

		humanoid:ApplyDescriptionReset(description)
		charModel:ScaleTo(charscale)
		if emotes and #emotes:GetChildren() > 0 then
			local anim = emotes:GetChildren()[math.random(#emotes:GetChildren())]
			local track = animator:LoadAnimation(anim)
			track.Looped = true
			track:Play()
		end
	end)
end

local function RefreshLeaderboard(leaderboardGui, statKey, showAvatars)
	for _, child in ipairs(leaderboardGui.Container.ScrollingFrame:GetChildren()) do
		if child:IsA("GuiObject") then
			TweenGroupTransparency(child, 1, 0.25)
			task.wait(0.25)
			child:Destroy()
		end
	end

	local success, data = pcall(function()
		return LbData[statKey .. "Lb"]:GetSortedAsync(false, 50)
	end)
	if not success or not data then
		return
	end

	local page = data:GetCurrentPage()
	for rank, entry in ipairs(page) do
		if not entry.value then
			continue
		end

		local template = PositionTemplates[rank == 1 and "First" or rank == 2 and "Second" or rank == 3 and "Third"]
		if not template then template = PositionTemplates.Others end
		template = template:Clone()
		
		FillTemplate(template, entry, rank, statKey)
		template.Parent = leaderboardGui.Container.ScrollingFrame
		if rank <=MaxAvaters and showAvatars then
			AddToSpot(entry,rank, leaderboardGui)
		end
	end
end

local function EmbedLeaderboard(leaderboardGui, statKey, showAvatars)
	ScrollingFrameAutoScale:Do(
		leaderboardGui.Container.ScrollingFrame,
		leaderboardGui.Container.ScrollingFrame.UIGridLayout,
		Enum.AutomaticSize.Y
	)

	while task.wait() do
		leaderboardGui.Container.RefreshingIn.Text = "Refreshing now..."
		pcall(function()
			for _, player in ipairs(Players:GetPlayers()) do
				-- local dataLoaded = player:FindFirstChild("DataLoaded")
				if player.UserId < 1 then
					continue
				end

				local stats = player:FindFirstChild("leaderstats")
				local privstats = player:FindFirstChild('PrivateStats')
				local Wins = stats and stats:FindFirstChild("Wins")
				local Loses = stats and stats:FindFirstChild("Loses")
				local Donate = privstats and privstats:FindFirstChild('Donate')
				-- local elims = stats and stats:FindFirstChild("Elims")

				local StatValues = {
					Wins = Wins,
					Donate = Donate,
					Loses = Loses,
				}
				local statValue = StatValues[statKey]
				-- print(statValue)
				if
					statValue
					and statValue.Value >= 0
					and not CollectionService:HasTag(player, "UpdatedLB" .. statKey)
				then
					LbData[statKey .. "Lb"]:UpdateAsync(player.UserId, function()
						return tonumber(statValue.Value)
					end)
					CollectionService:AddTag(player, "UpdatedLB" .. statKey)
					task.delay(5, function()
						CollectionService:RemoveTag(player, "UpdatedLB" .. statKey)
					end)
				end
			end
		end)

		RefreshLeaderboard(leaderboardGui, statKey, showAvatars)

		for i = 60, 1, -1 do
			leaderboardGui.Container.RefreshingIn.Text = "Refreshing in " .. i .. "s"
			task.wait(1)
		end
	end
end

--> Initialize DataStores
----------------------------------------
for key, storeName in pairs(Leaderboards) do
	local success, store = pcall(function()
		return DataStoreService:GetOrderedDataStore("Leaderboards1" .. storeName)
	end)
	if success then
		LbData[key] = store
	else
		warn("Failed to init datastore for", key)
	end
end

--> Public API
----------------------------------------
return {
	LbData = LbData,
	Embed = EmbedLeaderboard,
	FillTemplate = FillTemplate,
	AddToSpot = AddToSpot,
	PositionTemplates = PositionTemplates,
	Unicodes = {
		Wins = "🏆",
		Level = "🚩",
	},
}
