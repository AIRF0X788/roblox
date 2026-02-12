--[[
	LootboxUI.luau
	CS:GO-style lootbox opening animation with horizontal spin.
	Features:
	  - Horizontal scrolling carousel of brainrot items
	  - Smooth deceleration and stop on the winning item
	  - Sound effects (spin, rarity reveal)
	  - Visual effects (glow, particles, rarity colors)
	  - Suspenseful reveal animation
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared").Modules.GameConfig)
local UIBuilder = require(script.Parent.UIBuilder)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local LootboxUI = {}

-- Animation settings
local ITEM_WIDTH = 120
local ITEM_HEIGHT = 140
local ITEM_SPACING = 10
local VISIBLE_ITEMS = 7
local TOTAL_DISPLAY_ITEMS = 50  -- Items to generate for smooth loop

local SPIN_DURATION = 5  -- Total animation duration (seconds)
local SPIN_DISTANCE = 3500  -- Pixels to travel

-- UI elements
local screenGui
local containerFrame
local viewportFrame
local itemsFrame
local indicatorLine
local resultFrame

-- Animation state
local isAnimating = false
local currentConnection

------------------------------------------------------------
-- SOUND MANAGEMENT
------------------------------------------------------------

local function playSound(soundId: string, volume: number?)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume or 0.5
	sound.Parent = playerGui
	sound:Play()
	
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
	
	return sound
end

-- Sound IDs (using Roblox default sounds - you can replace these)
local SOUNDS = {
	Spin = "rbxasset://sounds/electronicpingshort.wav",  -- Replace with your spin sound
	Stop = "rbxasset://sounds/button.wav",  -- Replace with stop/tick sound
	Reveal = "rbxasset://sounds/victory.wav",  -- Replace with reveal sound
	Rare = "rbxasset://sounds/uuhhh.wav",  -- Replace with rare item sound
}

------------------------------------------------------------
-- CREATE LOOTBOX UI
------------------------------------------------------------

function LootboxUI.Create()
	screenGui = UIBuilder.CreateScreenGui("LootboxGui", playerGui)
	screenGui.Enabled = false  -- Hidden by default
	screenGui.DisplayOrder = 100  -- On top of everything
	
	-- Dark overlay background
	local overlay = UIBuilder.CreateFrame({
		Name = "Overlay",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.3,
		Parent = screenGui,
	})
	
	-- Main container
	containerFrame = UIBuilder.CreateFrame({
		Name = "Container",
		Size = UDim2.new(0, 900, 0, 300),
		Position = UDim2.new(0.5, -450, 0.5, -150),
		BackgroundColor3 = UIBuilder.Colors.Background,
		CornerRadius = UDim.new(0, 16),
		Parent = screenGui,
	})
	
	-- Title
	UIBuilder.CreateLabel({
		Name = "Title",
		Size = UDim2.new(1, -40, 0, 40),
		Position = UDim2.new(0, 20, 0, 10),
		Text = "🎁 OPENING BOX...",
		TextColor3 = UIBuilder.Colors.AccentGold,
		Font = Enum.Font.GothamBold,
		Parent = containerFrame,
	})
	
	-- Viewport frame (scrolling area)
	viewportFrame = UIBuilder.CreateFrame({
		Name = "Viewport",
		Size = UDim2.new(1, -40, 0, 180),
		Position = UDim2.new(0, 20, 0, 60),
		BackgroundColor3 = UIBuilder.Colors.BackgroundLight,
		CornerRadius = UDim.new(0, 12),
		Parent = containerFrame,
	})
	
	-- Clip descendants
	viewportFrame.ClipsDescendants = true
	
	-- Items frame (will scroll horizontally)
	itemsFrame = Instance.new("Frame")
	itemsFrame.Name = "ItemsFrame"
	itemsFrame.Size = UDim2.new(0, TOTAL_DISPLAY_ITEMS * (ITEM_WIDTH + ITEM_SPACING), 1, 0)
	itemsFrame.Position = UDim2.new(0, 0, 0, 0)
	itemsFrame.BackgroundTransparency = 1
	itemsFrame.Parent = viewportFrame
	
	-- Center indicator line (shows where item will land)
	indicatorLine = Instance.new("Frame")
	indicatorLine.Name = "Indicator"
	indicatorLine.Size = UDim2.new(0, 4, 1, 0)
	indicatorLine.Position = UDim2.new(0.5, -2, 0, 0)
	indicatorLine.BackgroundColor3 = UIBuilder.Colors.AccentGold
	indicatorLine.BorderSizePixel = 0
	indicatorLine.ZIndex = 10
	indicatorLine.Parent = viewportFrame
	
	-- Glow effect on indicator
	local glow = Instance.new("UIStroke")
	glow.Color = UIBuilder.Colors.AccentGold
	glow.Thickness = 3
	glow.Transparency = 0.5
	glow.Parent = indicatorLine
	
	-- Result frame (shown after animation)
	resultFrame = UIBuilder.CreateFrame({
		Name = "ResultFrame",
		Size = UDim2.new(0, 400, 0, 250),
		Position = UDim2.new(0.5, -200, 0.5, -125),
		BackgroundColor3 = UIBuilder.Colors.Background,
		CornerRadius = UDim.new(0, 16),
		BackgroundTransparency = 1,
		Parent = screenGui,
	})
	resultFrame.Visible = false
	
	print("[LootboxUI] UI created")
end

------------------------------------------------------------
-- GENERATE ITEM CARDS
------------------------------------------------------------

local function createItemCard(brainrot: any, index: number): Frame
	local card = UIBuilder.CreateFrame({
		Name = "ItemCard_" .. index,
		Size = UDim2.new(0, ITEM_WIDTH, 0, ITEM_HEIGHT),
		Position = UDim2.new(0, index * (ITEM_WIDTH + ITEM_SPACING), 0, 20),
		BackgroundColor3 = UIBuilder.Colors.BackgroundLight,
		CornerRadius = UDim.new(0, 10),
		Parent = itemsFrame,
	})
	
	-- Rarity color border
	local rarityData = GameConfig.Rarities[brainrot.Rarity]
	local rarityColor = rarityData and rarityData.Color or Color3.new(1, 1, 1)
	
	local border = Instance.new("UIStroke")
	border.Color = rarityColor
	border.Thickness = 3
	border.Parent = card
	
	-- Image
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Image"
	imageLabel.Size = UDim2.new(1, -20, 0, 80)
	imageLabel.Position = UDim2.new(0, 10, 0, 10)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = brainrot.ImageId or "rbxassetid://0"  -- Placeholder
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Parent = card
	
	-- Name label
	UIBuilder.CreateLabel({
		Name = "NameLabel",
		Size = UDim2.new(1, -10, 0, 25),
		Position = UDim2.new(0, 5, 0, 95),
		Text = brainrot.Name,
		TextColor3 = rarityColor,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		Parent = card,
	})
	
	-- Rarity label
	UIBuilder.CreateLabel({
		Name = "RarityLabel",
		Size = UDim2.new(1, -10, 0, 18),
		Position = UDim2.new(0, 5, 1, -23),
		Text = brainrot.Rarity,
		TextColor3 = UIBuilder.Colors.TextMuted,
		Font = Enum.Font.Gotham,
		TextSize = 10,
		Parent = card,
	})
	
	return card
end

------------------------------------------------------------
-- POPULATE ITEMS
------------------------------------------------------------

local function populateItems(wonBrainrots: {any})
	-- Clear existing items
	for _, child in ipairs(itemsFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	-- Generate random brainrots for the carousel
	local displayItems = {}
	
	-- Fill with random items
	for i = 1, TOTAL_DISPLAY_ITEMS do
		local randomBrainrot = GameConfig.Brainrots[math.random(1, #GameConfig.Brainrots)]
		table.insert(displayItems, {
			Name = randomBrainrot.Name,
			Rarity = randomBrainrot.Rarity,
			ImageId = randomBrainrot.ImageId,
			MoneyPerCycle = randomBrainrot.MoneyPerCycle,
		})
	end
	
	-- Place the actual won brainrots near the end (where the spin will stop)
	local stopIndex = TOTAL_DISPLAY_ITEMS - 5  -- 5 items before the end
	for i, brainrot in ipairs(wonBrainrots) do
		displayItems[stopIndex + i - 1] = brainrot
	end
	
	-- Create cards
	for i, item in ipairs(displayItems) do
		createItemCard(item, i - 1)
	end
	
	return stopIndex
end

------------------------------------------------------------
-- ANIMATE SPIN
------------------------------------------------------------

local function animateSpin(stopIndex: number, callback: () -> ())
	isAnimating = true
	
	-- Calculate stop position (center the winning item)
	local viewportCenter = viewportFrame.AbsoluteSize.X / 2
	local stopPosition = -(stopIndex * (ITEM_WIDTH + ITEM_SPACING)) + viewportCenter - (ITEM_WIDTH / 2)
	
	-- Play spin sound
	local spinSound = playSound(SOUNDS.Spin, 0.3)
	
	-- Initial fast scroll
	local startTime = tick()
	local initialSpeed = 2000  -- Pixels per second
	local deceleration = 400  -- Deceleration rate
	
	local currentPos = 0
	
	-- Animation loop
	currentConnection = RunService.RenderStepped:Connect(function()
		local elapsed = tick() - startTime
		
		if elapsed >= SPIN_DURATION then
			-- Stop animation
			itemsFrame.Position = UDim2.new(0, stopPosition, 0, 0)
			
			if currentConnection then
				currentConnection:Disconnect()
			end
			
			if spinSound then
				spinSound:Stop()
			end
			
			-- Play stop sound
			playSound(SOUNDS.Stop, 0.5)
			
			task.wait(0.3)
			isAnimating = false
			
			if callback then
				callback()
			end
			
			return
		end
		
		-- Calculate speed with deceleration
		local timeRemaining = SPIN_DURATION - elapsed
		local speed = math.max(50, initialSpeed * (timeRemaining / SPIN_DURATION))
		
		-- Update position
		currentPos = currentPos - (speed * (1/60))  -- 60 FPS assumption
		
		-- Add slight bounce effect near the end
		if timeRemaining < 0.5 then
			local bounce = math.sin(elapsed * 20) * 2
			currentPos = currentPos + bounce
		end
		
		itemsFrame.Position = UDim2.new(0, currentPos, 0, 0)
		
		-- Adjust to final position
		if elapsed > SPIN_DURATION * 0.9 then
			local alpha = (elapsed - SPIN_DURATION * 0.9) / (SPIN_DURATION * 0.1)
			currentPos = currentPos * (1 - alpha) + stopPosition * alpha
		end
	end)
end

------------------------------------------------------------
-- SHOW RESULT
------------------------------------------------------------

local function showResult(wonBrainrots: {any}, boxName: string)
	resultFrame.Visible = true
	resultFrame.BackgroundTransparency = 1
	
	-- Fade in background
	TweenService:Create(resultFrame, TweenInfo.new(0.3), {
		BackgroundTransparency = 0
	}):Play()
	
	-- Title
	local titleLabel = UIBuilder.CreateLabel({
		Name = "Title",
		Size = UDim2.new(1, -40, 0, 40),
		Position = UDim2.new(0, 20, 0, 10),
		Text = "🎉 " .. boxName .. " OPENED!",
		TextColor3 = UIBuilder.Colors.AccentGold,
		Font = Enum.Font.GothamBold,
		Parent = resultFrame,
	})
	
	-- Won items container
	local itemsContainer = Instance.new("Frame")
	itemsContainer.Name = "ItemsContainer"
	itemsContainer.Size = UDim2.new(1, -40, 0, 140)
	itemsContainer.Position = UDim2.new(0, 20, 0, 60)
	itemsContainer.BackgroundTransparency = 1
	itemsContainer.Parent = resultFrame
	
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 10)
	layout.Parent = itemsContainer
	
	-- Display each won brainrot
	for _, brainrot in ipairs(wonBrainrots) do
		local rarityData = GameConfig.Rarities[brainrot.Rarity]
		local rarityColor = rarityData and rarityData.Color or Color3.new(1, 1, 1)
		
		local itemCard = UIBuilder.CreateFrame({
			Name = "ResultCard",
			Size = UDim2.new(0, 100, 0, 130),
			BackgroundColor3 = UIBuilder.Colors.BackgroundLight,
			CornerRadius = UDim.new(0, 10),
			Parent = itemsContainer,
		})
		
		-- Border with rarity color
		local border = Instance.new("UIStroke")
		border.Color = rarityColor
		border.Thickness = 3
		border.Parent = itemCard
		
		-- Glow effect for rare items
		if rarityData and rarityData.GlowIntensity and rarityData.GlowIntensity > 0.5 then
			local glow = Instance.new("UIStroke")
			glow.Color = rarityColor
			glow.Thickness = 6
			glow.Transparency = 0.7
			glow.Parent = itemCard
		end
		
		-- Image
		local image = Instance.new("ImageLabel")
		image.Size = UDim2.new(1, -10, 0, 70)
		image.Position = UDim2.new(0, 5, 0, 5)
		image.BackgroundTransparency = 1
		image.Image = brainrot.ImageId or "rbxassetid://0"
		image.ScaleType = Enum.ScaleType.Fit
		image.Parent = itemCard
		
		-- Name
		UIBuilder.CreateLabel({
			Name = "Name",
			Size = UDim2.new(1, -5, 0, 25),
			Position = UDim2.new(0, 2.5, 0, 80),
			Text = brainrot.Name,
			TextColor3 = rarityColor,
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			Parent = itemCard,
		})
		
		-- Rarity
		UIBuilder.CreateLabel({
			Name = "Rarity",
			Size = UDim2.new(1, -5, 0, 18),
			Position = UDim2.new(0, 2.5, 1, -23),
			Text = brainrot.Rarity,
			TextColor3 = UIBuilder.Colors.TextMuted,
			Font = Enum.Font.Gotham,
			TextSize = 9,
			Parent = itemCard,
		})
	end
	
	-- Close button
	local closeBtn = UIBuilder.CreateButton({
		Name = "CloseButton",
		Size = UDim2.new(0, 150, 0, 40),
		Position = UDim2.new(0.5, -75, 1, -50),
		Text = "✓ Continue",
		BackgroundColor3 = UIBuilder.Colors.AccentGreen,
		Font = Enum.Font.GothamBold,
		CornerRadius = UDim.new(0, 10),
		OnClick = function()
			LootboxUI.Hide()
		end,
		Parent = resultFrame,
	})
	
	-- Play reveal sound based on highest rarity
	local highestOrder = 0
	for _, brainrot in ipairs(wonBrainrots) do
		local rarityData = GameConfig.Rarities[brainrot.Rarity]
		if rarityData and rarityData.Order > highestOrder then
			highestOrder = rarityData.Order
		end
	end
	
	if highestOrder >= 5 then  -- Legendary or higher
		playSound(SOUNDS.Rare, 0.7)
	else
		playSound(SOUNDS.Reveal, 0.5)
	end
end

------------------------------------------------------------
-- OPEN LOOTBOX (Main function)
------------------------------------------------------------

function LootboxUI.OpenBox(boxName: string, wonBrainrots: {any})
	if isAnimating then
		warn("[LootboxUI] Animation already in progress")
		return
	end
	
	print("[LootboxUI] Opening box: " .. boxName)
	
	-- Show UI
	screenGui.Enabled = true
	resultFrame.Visible = false
	
	-- Clear result frame children
	for _, child in ipairs(resultFrame:GetChildren()) do
		if not child:IsA("UICorner") then
			child:Destroy()
		end
	end
	
	-- Populate items
	local stopIndex = populateItems(wonBrainrots)
	
	-- Reset position
	itemsFrame.Position = UDim2.new(0, 0, 0, 0)
	
	-- Small delay before starting
	task.wait(0.5)
	
	-- Start animation
	animateSpin(stopIndex, function()
		-- Show result after spin completes
		task.wait(0.5)
		showResult(wonBrainrots, boxName)
	end)
end

------------------------------------------------------------
-- HIDE UI
------------------------------------------------------------

function LootboxUI.Hide()
	if currentConnection then
		currentConnection:Disconnect()
		currentConnection = nil
	end
	
	isAnimating = false
	screenGui.Enabled = false
	
	print("[LootboxUI] Hidden")
end

------------------------------------------------------------
-- CHECK IF ANIMATING
------------------------------------------------------------

function LootboxUI.IsAnimating(): boolean
	return isAnimating
end

return LootboxUI
