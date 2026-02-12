--[[
	NotificationUI.luau
	Shows floating notifications that appear and disappear.
	Supports different colors for success, error, info, etc.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local UIBuilder = require(script.Parent.UIBuilder)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local NotificationUI = {}

local screenGui
local notifContainer
local MAX_NOTIFS = 5

function NotificationUI.Create()
	screenGui = UIBuilder.CreateScreenGui("NotificationGui", playerGui)
	screenGui.DisplayOrder = 100  -- always on top

	-- Container at top-right
	notifContainer = UIBuilder.CreateFrame({
		Name = "NotifContainer",
		Size = UDim2.new(0, 300, 0, 400),
		Position = UDim2.new(1, -310, 0, 60),
		BackgroundTransparency = 1,
		Parent = screenGui,
	})

	UIBuilder.AddListLayout(notifContainer, UDim.new(0, 6))
end

------------------------------------------------------------
-- SHOW NOTIFICATION
------------------------------------------------------------

function NotificationUI.Show(data: { Title: string, Text: string, Color: Color3? })
	if not notifContainer then return end

	local color = data.Color or UIBuilder.Colors.Accent

	-- Limit notifications
	local children = notifContainer:GetChildren()
	local frameCount = 0
	for _, child in ipairs(children) do
		if child:IsA("Frame") then
			frameCount = frameCount + 1
		end
	end
	if frameCount >= MAX_NOTIFS then
		-- Remove oldest
		for _, child in ipairs(children) do
			if child:IsA("Frame") then
				child:Destroy()
				break
			end
		end
	end

	-- Create notification frame
	local notif = UIBuilder.CreateFrame({
		Name = "Notif",
		Size = UDim2.new(1, 0, 0, 60),
		BackgroundColor3 = Color3.fromRGB(20, 20, 30),
		BackgroundTransparency = 0.1,
		CornerRadius = UDim.new(0, 8),
		Parent = notifContainer,
	})

	-- Color accent bar on left
	local accent = UIBuilder.CreateFrame({
		Name = "Accent",
		Size = UDim2.new(0, 4, 1, -8),
		Position = UDim2.new(0, 4, 0, 4),
		BackgroundColor3 = color,
		CornerRadius = UDim.new(0, 2),
		Parent = notif,
	})

	-- Title
	UIBuilder.CreateLabel({
		Name = "Title",
		Size = UDim2.new(1, -20, 0, 24),
		Position = UDim2.new(0, 14, 0, 4),
		Text = data.Title or "Notification",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = color,
		Font = Enum.Font.GothamBold,
		Parent = notif,
	})

	-- Text
	UIBuilder.CreateLabel({
		Name = "Text",
		Size = UDim2.new(1, -20, 0, 28),
		Position = UDim2.new(0, 14, 0, 28),
		Text = data.Text or "",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = UIBuilder.Colors.TextSecondary,
		Font = Enum.Font.Gotham,
		Parent = notif,
	})

	-- Animate in
	notif.BackgroundTransparency = 1
	local tweenIn = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		BackgroundTransparency = 0.1,
	})
	tweenIn:Play()

	-- Auto-remove after 4 seconds
	task.delay(4, function()
		if notif and notif.Parent then
			local tweenOut = TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				BackgroundTransparency = 1,
			})
			tweenOut:Play()
			tweenOut.Completed:Wait()
			if notif and notif.Parent then
				notif:Destroy()
			end
		end
	end)
end

------------------------------------------------------------
-- BOX PURCHASED NOTIFICATION (special animated one)
------------------------------------------------------------

function NotificationUI.ShowBoxPurchase(data: { BoxName: string, Rarity: string, Brainrots: { any } })
	local GameConfig = require(game:GetService("ReplicatedStorage").Shared.Modules.GameConfig)
	local rarityData = GameConfig.Rarities[data.Rarity]
	local color = rarityData and rarityData.Color or Color3.new(1, 1, 1)

	local brainrotNames = {}
	for _, b in ipairs(data.Brainrots or {}) do
		table.insert(brainrotNames, b.Name .. " (" .. b.Rarity .. ")")
	end
	local brainrotText = table.concat(brainrotNames, ", ")

	NotificationUI.Show({
		Title = "📦 " .. data.BoxName .. " Opened!",
		Text = "Got: " .. brainrotText,
		Color = color,
	})
end

------------------------------------------------------------
-- COLLECTION COMPLETED (gold notification)
------------------------------------------------------------

function NotificationUI.ShowCollectionComplete(data: { CollectionName: string, Reward: number })
	local Utils = require(game:GetService("ReplicatedStorage").Shared.Modules.Utils)
	NotificationUI.Show({
		Title = "🏆 COLLECTION COMPLETE!",
		Text = data.CollectionName .. " - " .. Utils.FormatMoney(data.Reward),
		Color = Color3.fromRGB(255, 215, 0),
	})
end

return NotificationUI
