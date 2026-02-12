--[[
	BrainrotListUI.luau
	Shows a panel listing all owned brainrots with sell buttons.
	Accessible via a toggle button at the bottom of the screen.
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

local BrainrotListUI = {}

local screenGui
local panelFrame
local scrollFrame
local toggleButton
local isPanelOpen = false

function BrainrotListUI.Create()
	screenGui = UIBuilder.CreateScreenGui("BrainrotListGui", playerGui)

	-- Toggle button at bottom center
	toggleButton = UIBuilder.CreateButton({
		Name = "BrainrotListToggle",
		Size = UDim2.new(0, 160, 0, 40),
		Position = UDim2.new(0.5, -80, 1, -50),
		Text = "🧠 My Brainrots",
		BackgroundColor3 = Color3.fromRGB(100, 50, 150),
		CornerRadius = UDim.new(0, 10),
		OnClick = function()
			isPanelOpen = not isPanelOpen
			BrainrotListUI.TogglePanel(isPanelOpen)
		end,
		Parent = screenGui,
	})

	-- Panel
	panelFrame = UIBuilder.CreateFrame({
		Name = "BrainrotListPanel",
		Size = UDim2.new(0, 340, 0, 400),
		Position = UDim2.new(0.5, -170, 1, 10),  -- offscreen
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = UIBuilder.Colors.Background,
		CornerRadius = UDim.new(0, 12),
		Parent = screenGui,
	})

	-- Title
	UIBuilder.CreateLabel({
		Name = "Title",
		Size = UDim2.new(1, -40, 0, 35),  -- Reduced width for close button
		Position = UDim2.new(0, 0, 0, 5),
		Text = "🧠 MY BRAINROTS",
		TextColor3 = Color3.fromRGB(200, 100, 255),
		Font = Enum.Font.GothamBold,
		Parent = panelFrame,
	})

	-- Close button (X)
	local closeButton = UIBuilder.CreateButton({
		Name = "CloseButton",
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -35, 0, 5),
		Text = "✕",
		BackgroundColor3 = UIBuilder.Colors.AccentRed,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		CornerRadius = UDim.new(0, 6),
		OnClick = function()
			isPanelOpen = false
			BrainrotListUI.TogglePanel(false)
		end,
		Parent = panelFrame,
	})

	-- Scroll frame
	scrollFrame = UIBuilder.CreateScrollFrame({
		Name = "BrainrotScroll",
		Size = UDim2.new(1, -16, 1, -50),
		Position = UDim2.new(0, 8, 0, 45),
		Parent = panelFrame,
	})

	UIBuilder.AddListLayout(scrollFrame, UDim.new(0, 4))
end

function BrainrotListUI.TogglePanel(open: boolean)
	if open then
		panelFrame.Position = UDim2.new(0.5, -170, 1, -410)
	else
		panelFrame.Position = UDim2.new(0.5, -170, 1, 10)
	end
end

------------------------------------------------------------
-- UPDATE BRAINROT LIST
------------------------------------------------------------

function BrainrotListUI.UpdateList(brainrots: { any })
	-- Clear existing
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	if #brainrots == 0 then
		UIBuilder.CreateLabel({
			Name = "Empty",
			Size = UDim2.new(1, 0, 0, 40),
			Text = "No brainrots yet! Buy some boxes!",
			TextColor3 = UIBuilder.Colors.TextMuted,
			Font = Enum.Font.Gotham,
			Parent = scrollFrame,
		})
		return
	end

	-- Sort by rarity (highest first)
	local sorted = {}
	for _, b in ipairs(brainrots) do
		table.insert(sorted, b)
	end
	table.sort(sorted, function(a, b)
		local ra = GameConfig.Rarities[a.Rarity]
		local rb = GameConfig.Rarities[b.Rarity]
		return (ra and ra.Order or 0) > (rb and rb.Order or 0)
	end)

	for i, brainrot in ipairs(sorted) do
		local rarityData = GameConfig.Rarities[brainrot.Rarity]
		local rarityColor = rarityData and rarityData.Color or Color3.new(1, 1, 1)
		local sellValue = (brainrot.MoneyPerCycle or 0) * 5

		local row = UIBuilder.CreateFrame({
			Name = "Brainrot_" .. i,
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundColor3 = UIBuilder.Colors.BackgroundLight,
			CornerRadius = UDim.new(0, 6),
			Parent = scrollFrame,
		})
		row.LayoutOrder = i

		-- Rarity indicator
		local indicator = UIBuilder.CreateFrame({
			Name = "RarityIndicator",
			Size = UDim2.new(0, 4, 1, -8),
			Position = UDim2.new(0, 4, 0, 4),
			BackgroundColor3 = rarityColor,
			CornerRadius = UDim.new(0, 2),
			Parent = row,
		})

		-- Name
		UIBuilder.CreateLabel({
			Name = "Name",
			Size = UDim2.new(0.45, -20, 0, 22),
			Position = UDim2.new(0, 14, 0, 4),
			Text = brainrot.Name,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = rarityColor,
			Font = Enum.Font.GothamBold,
			Parent = row,
		})

		-- Rarity + income
		UIBuilder.CreateLabel({
			Name = "Info",
			Size = UDim2.new(0.45, -20, 0, 16),
			Position = UDim2.new(0, 14, 0, 28),
			Text = brainrot.Rarity .. " | " .. Utils.FormatMoney(brainrot.MoneyPerCycle or 0) .. "/cycle",
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = UIBuilder.Colors.TextMuted,
			Font = Enum.Font.Gotham,
			Parent = row,
		})

		-- Sell button
		local sellBtn = UIBuilder.CreateButton({
			Name = "SellBtn",
			Size = UDim2.new(0, 90, 0, 30),
			Position = UDim2.new(1, -100, 0.5, -15),
			Text = "Sell " .. Utils.FormatShort(sellValue),
			BackgroundColor3 = UIBuilder.Colors.AccentRed,
			Font = Enum.Font.GothamBold,
			CornerRadius = UDim.new(0, 6),
			OnClick = function()
				RemoteHelper.FireServer(RemoteNames.Events.RequestSellBrainrot, {
					BrainrotId = brainrot.Id,
				})
			end,
			Parent = row,
		})
	end
end

return BrainrotListUI
