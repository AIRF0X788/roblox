--[[
	UpgradeUI.luau
	Upgrade panel on the right side of the screen.
	Shows Base, Conveyor, and Luck upgrades with costs.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared").Modules.GameConfig)
local RemoteNames = require(ReplicatedStorage.Shared.Modules.RemoteNames)
local Utils = require(ReplicatedStorage.Shared.Modules.Utils)
local UIBuilder = require(script.Parent.UIBuilder)
local RemoteHelper = require(script.Parent.Parent.Controllers.RemoteHelper)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local UpgradeUI = {}

local screenGui
local panelFrame
local toggleButton
local isPanelOpen = false

-- Upgrade card references for dynamic updates
local baseCard = {}
local conveyorCard = {}
local luckCard = {}

------------------------------------------------------------
-- CREATE UPGRADE CARD
------------------------------------------------------------

local function createUpgradeCard(parent, name, icon, currentLevel, maxLevel, cost, description, onClick)
	local card = UIBuilder.CreateFrame({
		Name = name .. "Card",
		Size = UDim2.new(1, -16, 0, 100),
		BackgroundColor3 = UIBuilder.Colors.BackgroundLight,
		CornerRadius = UDim.new(0, 10),
		Parent = parent,
	})

	local iconLabel = UIBuilder.CreateLabel({
		Name = "Icon",
		Size = UDim2.new(0, 40, 0, 40),
		Position = UDim2.new(0, 10, 0, 10),
		Text = icon,
		Parent = card,
	})

	local titleLabel = UIBuilder.CreateLabel({
		Name = "Title",
		Size = UDim2.new(1, -70, 0, 22),
		Position = UDim2.new(0, 55, 0, 8),
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = UIBuilder.Colors.TextPrimary,
		Font = Enum.Font.GothamBold,
		Parent = card,
	})

	local levelLabel = UIBuilder.CreateLabel({
		Name = "Level",
		Size = UDim2.new(1, -70, 0, 18),
		Position = UDim2.new(0, 55, 0, 32),
		Text = "Level " .. currentLevel .. "/" .. maxLevel,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = UIBuilder.Colors.TextSecondary,
		Font = Enum.Font.Gotham,
		Parent = card,
	})

	local descLabel = UIBuilder.CreateLabel({
		Name = "Description",
		Size = UDim2.new(1, -20, 0, 16),
		Position = UDim2.new(0, 10, 0, 55),
		Text = description,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = UIBuilder.Colors.TextMuted,
		Font = Enum.Font.Gotham,
		Parent = card,
	})

	local upgradeBtn
	if cost then
		upgradeBtn = UIBuilder.CreateButton({
			Name = "UpgradeBtn",
			Size = UDim2.new(1, -20, 0, 28),
			Position = UDim2.new(0, 10, 1, -34),
			Text = "Upgrade - " .. Utils.FormatMoney(cost),
			BackgroundColor3 = UIBuilder.Colors.AccentGreen,
			Font = Enum.Font.GothamBold,
			CornerRadius = UDim.new(0, 6),
			OnClick = onClick,
			Parent = card,
		})
	else
		UIBuilder.CreateLabel({
			Name = "MaxLabel",
			Size = UDim2.new(1, -20, 0, 28),
			Position = UDim2.new(0, 10, 1, -34),
			Text = "MAX LEVEL",
			TextColor3 = UIBuilder.Colors.AccentGold,
			Font = Enum.Font.GothamBold,
			Parent = card,
		})
	end

	return {
		Card = card,
		LevelLabel = levelLabel,
		DescLabel = descLabel,
		UpgradeBtn = upgradeBtn,
	}
end

------------------------------------------------------------
-- CREATE UI
------------------------------------------------------------

function UpgradeUI.Create()
	screenGui = UIBuilder.CreateScreenGui("UpgradeGui", playerGui)

	-- Toggle button on right side
	toggleButton = UIBuilder.CreateButton({
		Name = "UpgradeToggle",
		Size = UDim2.new(0, 50, 0, 50),
		Position = UDim2.new(1, -60, 0.5, -25),
		Text = "🔧",
		BackgroundColor3 = UIBuilder.Colors.Accent,
		CornerRadius = UDim.new(0, 12),
		OnClick = function()
			isPanelOpen = not isPanelOpen
			UpgradeUI.TogglePanel(isPanelOpen)
		end,
		Parent = screenGui,
	})

	-- Panel
	panelFrame = UIBuilder.CreateFrame({
		Name = "UpgradePanel",
		Size = UDim2.new(0, 280, 0, 420),
		Position = UDim2.new(1, 10, 0.5, -210),  -- starts offscreen
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = UIBuilder.Colors.Background,
		CornerRadius = UDim.new(0, 12),
		Parent = screenGui,
	})

	-- Title
	UIBuilder.CreateLabel({
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 35),
		Position = UDim2.new(0, 0, 0, 5),
		Text = "⬆ UPGRADES",
		TextColor3 = UIBuilder.Colors.AccentGold,
		Font = Enum.Font.GothamBold,
		Parent = panelFrame,
	})

	-- Scroll frame for cards
	local scrollFrame = UIBuilder.CreateScrollFrame({
		Name = "CardScroll",
		Size = UDim2.new(1, 0, 1, -45),
		Position = UDim2.new(0, 0, 0, 42),
		Parent = panelFrame,
	})

	UIBuilder.AddListLayout(scrollFrame, UDim.new(0, 8))

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.PaddingTop = UDim.new(0, 4)
	padding.Parent = scrollFrame

	-- Create upgrade cards
	local baseCost = GameConfig.GetBaseUpgradeCost(1)
	local maxBrainrots = GameConfig.GetMaxBrainrots(1)
	baseCard = createUpgradeCard(
		scrollFrame, "Base", "🏠", 1, #GameConfig.BaseUpgrades,
		baseCost,
		"Max Brainrots: " .. maxBrainrots,
		function()
			RemoteHelper.FireServer(RemoteNames.Events.RequestUpgradeBase)
		end
	)

	local convCost = GameConfig.GetConveyorUpgradeCost(1)
	conveyorCard = createUpgradeCard(
		scrollFrame, "Conveyor", "🏭", 1, #GameConfig.ConveyorUpgrades,
		convCost,
		"Faster box spawning",
		function()
			RemoteHelper.FireServer(RemoteNames.Events.RequestUpgradeConveyor)
		end
	)

	local luckCost = GameConfig.GetLuckUpgradeCost(1)
	luckCard = createUpgradeCard(
		scrollFrame, "Luck", "🍀", 1, #GameConfig.LuckUpgrades,
		luckCost,
		"Better rarity chances",
		function()
			RemoteHelper.FireServer(RemoteNames.Events.RequestUpgradeLuck)
		end
	)
end

function UpgradeUI.TogglePanel(open: boolean)
	if open then
		panelFrame.Position = UDim2.new(1, -290, 0.5, -210)
	else
		panelFrame.Position = UDim2.new(1, 10, 0.5, -210)
	end
end

------------------------------------------------------------
-- UPDATE FUNCTIONS
------------------------------------------------------------

function UpgradeUI.UpdateBaseLevel(level: number)
	if not baseCard.LevelLabel then return end
	baseCard.LevelLabel.Text = "Level " .. level .. "/" .. #GameConfig.BaseUpgrades
	local maxB = GameConfig.GetMaxBrainrots(level)
	baseCard.DescLabel.Text = "Max Brainrots: " .. maxB

	local cost = GameConfig.GetBaseUpgradeCost(level)
	if baseCard.UpgradeBtn then
		if cost then
			baseCard.UpgradeBtn.Text = "Upgrade - " .. Utils.FormatMoney(cost)
			baseCard.UpgradeBtn.Visible = true
		else
			baseCard.UpgradeBtn.Text = "MAX LEVEL"
			baseCard.UpgradeBtn.BackgroundColor3 = UIBuilder.Colors.AccentGold
		end
	end
end

function UpgradeUI.UpdateConveyorLevel(level: number)
	if not conveyorCard.LevelLabel then return end
	conveyorCard.LevelLabel.Text = "Level " .. level .. "/" .. #GameConfig.ConveyorUpgrades

	local cost = GameConfig.GetConveyorUpgradeCost(level)
	if conveyorCard.UpgradeBtn then
		if cost then
			conveyorCard.UpgradeBtn.Text = "Upgrade - " .. Utils.FormatMoney(cost)
			conveyorCard.UpgradeBtn.Visible = true
		else
			conveyorCard.UpgradeBtn.Text = "MAX LEVEL"
			conveyorCard.UpgradeBtn.BackgroundColor3 = UIBuilder.Colors.AccentGold
		end
	end
end

function UpgradeUI.UpdateLuckLevel(level: number)
	if not luckCard.LevelLabel then return end
	luckCard.LevelLabel.Text = "Level " .. level .. "/" .. #GameConfig.LuckUpgrades

	local cost = GameConfig.GetLuckUpgradeCost(level)
	if luckCard.UpgradeBtn then
		if cost then
			luckCard.UpgradeBtn.Text = "Upgrade - " .. Utils.FormatMoney(cost)
			luckCard.UpgradeBtn.Visible = true
		else
			luckCard.UpgradeBtn.Text = "MAX LEVEL"
			luckCard.UpgradeBtn.BackgroundColor3 = UIBuilder.Colors.AccentGold
		end
	end
end

return UpgradeUI
