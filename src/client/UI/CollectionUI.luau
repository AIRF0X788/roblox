--[[
	CollectionUI.luau
	Shows the collections tab where players can see
	which brainrots they've collected and collection progress.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared").Modules.GameConfig)
local Utils = require(ReplicatedStorage.Shared.Modules.Utils)
local UIBuilder = require(script.Parent.UIBuilder)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CollectionUI = {}

local screenGui
local panelFrame
local scrollFrame
local toggleButton
local isPanelOpen = false

------------------------------------------------------------
-- CREATE
------------------------------------------------------------

function CollectionUI.Create()
	screenGui = UIBuilder.CreateScreenGui("CollectionGui", playerGui)

	-- Toggle button on left side
	toggleButton = UIBuilder.CreateButton({
		Name = "CollectionToggle",
		Size = UDim2.new(0, 50, 0, 50),
		Position = UDim2.new(0, 10, 0.5, -25),
		Text = "📚",
		BackgroundColor3 = Color3.fromRGB(200, 150, 50),
		CornerRadius = UDim.new(0, 12),
		OnClick = function()
			isPanelOpen = not isPanelOpen
			CollectionUI.TogglePanel(isPanelOpen)
		end,
		Parent = screenGui,
	})

	-- Main panel
	panelFrame = UIBuilder.CreateFrame({
		Name = "CollectionPanel",
		Size = UDim2.new(0, 350, 0, 500),
		Position = UDim2.new(0, -360, 0.5, -250),  -- offscreen
		BackgroundColor3 = UIBuilder.Colors.Background,
		CornerRadius = UDim.new(0, 12),
		Parent = screenGui,
	})

	-- Title
	UIBuilder.CreateLabel({
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 35),
		Position = UDim2.new(0, 0, 0, 5),
		Text = "📚 COLLECTIONS",
		TextColor3 = UIBuilder.Colors.AccentGold,
		Font = Enum.Font.GothamBold,
		Parent = panelFrame,
	})

	-- Scroll frame
	scrollFrame = UIBuilder.CreateScrollFrame({
		Name = "CollectionScroll",
		Size = UDim2.new(1, -16, 1, -50),
		Position = UDim2.new(0, 8, 0, 45),
		Parent = panelFrame,
	})

	UIBuilder.AddListLayout(scrollFrame, UDim.new(0, 8))

	-- Build initial collection cards
	CollectionUI.BuildCollectionCards({})
end

function CollectionUI.TogglePanel(open: boolean)
	if open then
		panelFrame.Position = UDim2.new(0, 10, 0.5, -250)
	else
		panelFrame.Position = UDim2.new(0, -360, 0.5, -250)
	end
end

------------------------------------------------------------
-- BUILD COLLECTION CARDS
------------------------------------------------------------

function CollectionUI.BuildCollectionCards(collectionStatus: { any })
	-- Clear existing cards
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Use config if no status provided
	local collections = GameConfig.Collections

	for i, collection in ipairs(collections) do
		-- Find matching status
		local status = nil
		for _, s in ipairs(collectionStatus) do
			if s.Name == collection.Name then
				status = s
				break
			end
		end

		local isCompleted = status and status.Completed or false
		local progress = status and status.Progress or "0/" .. #collection.RequiredBrainrots

		-- Card frame
		local card = UIBuilder.CreateFrame({
			Name = "Collection_" .. i,
			Size = UDim2.new(1, 0, 0, 30 + #collection.RequiredBrainrots * 24 + 40),
			BackgroundColor3 = isCompleted and Color3.fromRGB(25, 45, 25) or UIBuilder.Colors.BackgroundLight,
			CornerRadius = UDim.new(0, 8),
			Parent = scrollFrame,
		})
		card.LayoutOrder = i

		-- Collection name + progress
		local headerFrame = UIBuilder.CreateFrame({
			Name = "Header",
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			Parent = card,
		})

		local statusIcon = isCompleted and "✅ " or "📋 "
		UIBuilder.CreateLabel({
			Name = "CollName",
			Size = UDim2.new(0.7, -10, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			Text = statusIcon .. collection.Name,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = isCompleted and UIBuilder.Colors.AccentGreen or UIBuilder.Colors.TextPrimary,
			Font = Enum.Font.GothamBold,
			Parent = headerFrame,
		})

		UIBuilder.CreateLabel({
			Name = "Progress",
			Size = UDim2.new(0.3, -10, 1, 0),
			Position = UDim2.new(0.7, 0, 0, 0),
			Text = progress,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = isCompleted and UIBuilder.Colors.AccentGreen or UIBuilder.Colors.Accent,
			Font = Enum.Font.GothamBold,
			Parent = headerFrame,
		})

		-- Brainrot list
		for j, requiredName in ipairs(collection.RequiredBrainrots) do
			local owned = false
			if status then
				for _, b in ipairs(status.Brainrots or {}) do
					if b.Name == requiredName and b.Owned then
						owned = true
						break
					end
				end
			end

			local brainrotConfig = GameConfig.BrainrotsByName[requiredName]
			local rarityColor = brainrotConfig and GameConfig.Rarities[brainrotConfig.Rarity] and GameConfig.Rarities[brainrotConfig.Rarity].Color or UIBuilder.Colors.TextMuted

			local brainrotLabel = UIBuilder.CreateLabel({
				Name = "Brainrot_" .. j,
				Size = UDim2.new(1, -20, 0, 20),
				Position = UDim2.new(0, 20, 0, 30 + (j - 1) * 24),
				Text = (owned and "✓ " or "✗ ") .. requiredName,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = owned and rarityColor or UIBuilder.Colors.TextMuted,
				Font = owned and Enum.Font.GothamBold or Enum.Font.Gotham,
				Parent = card,
			})
		end

		-- Reward
		UIBuilder.CreateLabel({
			Name = "Reward",
			Size = UDim2.new(1, -20, 0, 22),
			Position = UDim2.new(0, 10, 1, -28),
			Text = "Reward: " .. Utils.FormatMoney(collection.Reward),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = isCompleted and UIBuilder.Colors.AccentGold or UIBuilder.Colors.TextSecondary,
			Font = Enum.Font.GothamBold,
			Parent = card,
		})
	end
end

------------------------------------------------------------
-- UPDATE
------------------------------------------------------------

function CollectionUI.UpdateCollections(collectionStatus: { any })
	CollectionUI.BuildCollectionCards(collectionStatus)
end

return CollectionUI
