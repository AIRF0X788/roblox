--[[
	LeaderboardUI.luau
	Shows a custom leaderboard panel with player rankings.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utils = require(ReplicatedStorage:WaitForChild("Shared").Modules.Utils)
local UIBuilder = require(script.Parent.UIBuilder)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local LeaderboardUI = {}

local screenGui
local panelFrame
local scrollFrame
local toggleButton
local isPanelOpen = false

function LeaderboardUI.Create()
	screenGui = UIBuilder.CreateScreenGui("LeaderboardGui", playerGui)

	-- Toggle button at top-right area
	toggleButton = UIBuilder.CreateButton({
		Name = "LeaderboardToggle",
		Size = UDim2.new(0, 50, 0, 50),
		Position = UDim2.new(1, -60, 0, 60),
		Text = "🏆",
		BackgroundColor3 = Color3.fromRGB(200, 150, 50),
		CornerRadius = UDim.new(0, 12),
		OnClick = function()
			isPanelOpen = not isPanelOpen
			LeaderboardUI.TogglePanel(isPanelOpen)
		end,
		Parent = screenGui,
	})

	-- Panel
	panelFrame = UIBuilder.CreateFrame({
		Name = "LeaderboardPanel",
		Size = UDim2.new(0, 300, 0, 400),
		Position = UDim2.new(1, 10, 0, 60),  -- offscreen
		BackgroundColor3 = UIBuilder.Colors.Background,
		CornerRadius = UDim.new(0, 12),
		Parent = screenGui,
	})

	-- Title
	UIBuilder.CreateLabel({
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 35),
		Position = UDim2.new(0, 0, 0, 5),
		Text = "🏆 LEADERBOARD",
		TextColor3 = UIBuilder.Colors.AccentGold,
		Font = Enum.Font.GothamBold,
		Parent = panelFrame,
	})

	-- Scroll
	scrollFrame = UIBuilder.CreateScrollFrame({
		Name = "LBScroll",
		Size = UDim2.new(1, -16, 1, -50),
		Position = UDim2.new(0, 8, 0, 45),
		Parent = panelFrame,
	})

	UIBuilder.AddListLayout(scrollFrame, UDim.new(0, 4))
end

function LeaderboardUI.TogglePanel(open: boolean)
	if open then
		panelFrame.Position = UDim2.new(1, -310, 0, 60)
	else
		panelFrame.Position = UDim2.new(1, 10, 0, 60)
	end
end

------------------------------------------------------------
-- UPDATE LEADERBOARD
------------------------------------------------------------

function LeaderboardUI.UpdateLeaderboard(rankings: { any })
	if not scrollFrame then return end

	-- Clear existing
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	if #rankings == 0 then
		UIBuilder.CreateLabel({
			Name = "Empty",
			Size = UDim2.new(1, 0, 0, 30),
			Text = "No players yet...",
			TextColor3 = UIBuilder.Colors.TextMuted,
			Parent = scrollFrame,
		})
		return
	end

	local medalColors = {
		[1] = Color3.fromRGB(255, 215, 0),   -- Gold
		[2] = Color3.fromRGB(192, 192, 192), -- Silver
		[3] = Color3.fromRGB(205, 127, 50),  -- Bronze
	}

	for i, entry in ipairs(rankings) do
		local isLocal = entry.Name == player.Name
		local medalColor = medalColors[i]

		local row = UIBuilder.CreateFrame({
			Name = "Rank_" .. i,
			Size = UDim2.new(1, 0, 0, 45),
			BackgroundColor3 = isLocal and Color3.fromRGB(30, 40, 60) or UIBuilder.Colors.BackgroundLight,
			CornerRadius = UDim.new(0, 6),
			Parent = scrollFrame,
		})
		row.LayoutOrder = i

		-- Rank number
		UIBuilder.CreateLabel({
			Name = "Rank",
			Size = UDim2.new(0, 30, 1, 0),
			Position = UDim2.new(0, 5, 0, 0),
			Text = "#" .. tostring(i),
			TextColor3 = medalColor or UIBuilder.Colors.TextSecondary,
			Font = Enum.Font.GothamBold,
			Parent = row,
		})

		-- Player name
		UIBuilder.CreateLabel({
			Name = "PlayerName",
			Size = UDim2.new(0.5, -40, 0, 22),
			Position = UDim2.new(0, 40, 0, 4),
			Text = entry.DisplayName or entry.Name,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = isLocal and UIBuilder.Colors.Accent or UIBuilder.Colors.TextPrimary,
			Font = Enum.Font.GothamBold,
			Parent = row,
		})

		-- Money
		UIBuilder.CreateLabel({
			Name = "Money",
			Size = UDim2.new(0.5, -10, 0, 18),
			Position = UDim2.new(0, 40, 0, 25),
			Text = Utils.FormatMoney(entry.TotalEarned or 0) .. " earned",
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = UIBuilder.Colors.AccentGold,
			Font = Enum.Font.Gotham,
			Parent = row,
		})

		-- Brainrot count
		UIBuilder.CreateLabel({
			Name = "Brainrots",
			Size = UDim2.new(0, 80, 1, 0),
			Position = UDim2.new(1, -85, 0, 0),
			Text = "🧠 " .. tostring(entry.BrainrotCount or 0),
			TextColor3 = UIBuilder.Colors.TextSecondary,
			Font = Enum.Font.GothamBold,
			Parent = row,
		})
	end
end

return LeaderboardUI
