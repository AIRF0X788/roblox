--[[
	ConveyorManager.luau
	Manages conveyor belts for each player:
	  - Spawns boxes at intervals
	  - Moves boxes along the belt
	  - Handles box purchasing
	  - Removes unpurchased boxes at the end
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)
local RemoteNames = require(ReplicatedStorage.Shared.Modules.RemoteNames)
local Utils = require(ReplicatedStorage.Shared.Modules.Utils)
local RemoteSetup = require(script.Parent.RemoteSetup)
local BaseBuilder = require(script.Parent.BaseBuilder)
local DataManager = require(script.Parent.DataManager)

local ConveyorManager = {}

-- Active boxes on each player's conveyor: [userId] = { {boxData}, ... }
local playerConveyors = {}

-- Active box parts in workspace: [boxId] = Part
local boxParts = {}

-- Running state
local playerRunning = {}

------------------------------------------------------------
-- BOX CREATION (Visual)
------------------------------------------------------------

local function createBoxPart(boxConfig, rarity, position: Vector3, boxId: string): Part
	local rarityData = GameConfig.Rarities[rarity]
	local size = boxConfig.Size or Vector3.new(3, 3, 3)

	local part = Instance.new("Part")
	part.Name = "Box_" .. boxId
	part.Size = size
	part.Position = position + Vector3.new(0, size.Y / 2 + 0.2, 0)
	part.Anchored = true
	part.CanCollide = false
	part.Color = rarityData.Color
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth

	-- Add glow for rare+ boxes
	if rarityData.GlowIntensity > 0 then
		local light = Instance.new("PointLight")
		light.Color = rarityData.Color
		light.Brightness = rarityData.GlowIntensity * 2
		light.Range = 8 + rarityData.GlowIntensity * 5
		light.Parent = part
	end

	-- Billboard GUI showing box name + price
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BoxInfo"
	billboard.Size = UDim2.new(0, 200, 0, 80)
	billboard.StudsOffset = Vector3.new(0, size.Y / 2 + 1.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "BoxName"
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.Text = boxConfig.Name
	nameLabel.TextColor3 = rarityData.Color
	nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	nameLabel.TextStrokeTransparency = 0.3
	nameLabel.TextScaled = true
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = billboard

	local priceLabel = Instance.new("TextLabel")
	priceLabel.Name = "Price"
	priceLabel.Size = UDim2.new(1, 0, 0.5, 0)
	priceLabel.Position = UDim2.new(0, 0, 0.5, 0)
	priceLabel.Text = Utils.FormatMoney(boxConfig.Price)
	priceLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
	priceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	priceLabel.TextStrokeTransparency = 0.3
	priceLabel.TextScaled = true
	priceLabel.BackgroundTransparency = 1
	priceLabel.Font = Enum.Font.GothamBold
	priceLabel.Parent = billboard

	-- Click detector for purchasing
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 30
	clickDetector.Parent = part

	return part
end

------------------------------------------------------------
-- CONVEYOR LOGIC
------------------------------------------------------------

local function spawnBox(player: Player)
	local userId = player.UserId
	if not playerConveyors[userId] then 
		warn("[ConveyorManager] No conveyor data for " .. player.Name)
		return 
	end
	if #playerConveyors[userId] >= GameConfig.Conveyor.MaxBoxesOnBelt then 
		print("[ConveyorManager] Belt full for " .. player.Name)
		return 
	end

	local startPos = BaseBuilder.GetConveyorStart(player)
	if not startPos then 
		warn("[ConveyorManager] ConveyorStart not found for " .. player.Name)
		return 
	end

	-- Pick rarity based on player's luck
	local luckLevel = DataManager.GetLuckLevel(player)
	local luckUpgrade = GameConfig.LuckUpgrades[luckLevel]
	local luckBoost = luckUpgrade and luckUpgrade.RarityBoost or 0
	local rarity = GameConfig.PickRandomBoxRarity(luckBoost)
	local boxConfig = GameConfig.GetBoxForRarity(rarity)

	local boxId = Utils.GenerateId()

	-- Create box data
	local boxData = {
		Id = boxId,
		BoxName = boxConfig.Name,
		Rarity = rarity,
		Price = boxConfig.Price,
		BrainrotCount = boxConfig.BrainrotCount,
		SpawnTime = tick(),
		Progress = 0,  -- 0 = start, 1 = end
	}

	table.insert(playerConveyors[userId], boxData)

	-- Create visual part
	local part = createBoxPart(boxConfig, rarity, startPos, boxId)
	part.Parent = game.Workspace
	boxParts[boxId] = part
	
	print("[ConveyorManager] ✅ Spawned box: " .. boxConfig.Name .. " for " .. player.Name)

	-- Set up click detection for buying
	local clickDetector = part:FindFirstChild("ClickDetector")
	if clickDetector then
		clickDetector.MouseClick:Connect(function(clickPlayer)
			if clickPlayer == player then
				ConveyorManager.TryBuyBox(player, boxId)
			end
		end)
	end

	-- Fire client event
	local spawnEvent = RemoteSetup.GetEvent(RemoteNames.Events.SpawnBoxOnBelt)
	if spawnEvent then
		spawnEvent:FireClient(player, {
			BoxId = boxId,
			BoxName = boxConfig.Name,
			Rarity = rarity,
			Price = boxConfig.Price,
		})
	end
end

local function removeBox(player: Player, boxId: string, reason: string)
	local userId = player.UserId
	if not playerConveyors[userId] then return end

	-- Remove from data
	for i, boxData in ipairs(playerConveyors[userId]) do
		if boxData.Id == boxId then
			table.remove(playerConveyors[userId], i)
			break
		end
	end

	-- Remove visual
	local part = boxParts[boxId]
	if part then
		part:Destroy()
		boxParts[boxId] = nil
	end

	-- Fire client event
	local removeEvent = RemoteSetup.GetEvent(RemoteNames.Events.RemoveBoxFromBelt)
	if removeEvent then
		removeEvent:FireClient(player, { BoxId = boxId, Reason = reason })
	end
end

local function updateConveyor(player: Player, dt: number)
	local userId = player.UserId
	if not playerConveyors[userId] then return end

	local startPos = BaseBuilder.GetConveyorStart(player)
	local endPos = BaseBuilder.GetConveyorEnd(player)
	if not startPos or not endPos then return end

	local conveyorLevel = DataManager.GetConveyorLevel(player)
	local convUpgrade = GameConfig.ConveyorUpgrades[conveyorLevel]
	local speedMult = convUpgrade and convUpgrade.SpeedMultiplier or 1

	local beltLength = (endPos - startPos).Magnitude
	local direction = (endPos - startPos).Unit
	local speed = GameConfig.Conveyor.BoxSpeed * speedMult

	local boxesToRemove = {}

	for _, boxData in ipairs(playerConveyors[userId]) do
		-- Update progress
		boxData.Progress = boxData.Progress + (speed / beltLength) * dt

		if boxData.Progress >= 1 then
			table.insert(boxesToRemove, boxData.Id)
		else
			-- Update visual position
			local part = boxParts[boxData.Id]
			if part then
				local pos = startPos + direction * (boxData.Progress * beltLength)
				part.Position = Vector3.new(pos.X, startPos.Y + part.Size.Y / 2 + 0.2, pos.Z)
			end
		end
	end

	-- Remove boxes that reached the end
	for _, boxId in ipairs(boxesToRemove) do
		removeBox(player, boxId, "expired")
	end
end

------------------------------------------------------------
-- PUBLIC API
------------------------------------------------------------

function ConveyorManager.StartConveyor(player: Player)
	local userId = player.UserId
	playerConveyors[userId] = {}
	playerRunning[userId] = true

	print("[ConveyorManager] Starting conveyor for " .. player.Name)

	-- Box spawning loop
	task.spawn(function()
		-- Wait a bit for base to be fully set up
		task.wait(0.5)
		
		print("[ConveyorManager] Starting spawn loop for " .. player.Name)
		
		while playerRunning[userId] do
			local conveyorLevel = DataManager.GetConveyorLevel(player)
			local convUpgrade = GameConfig.ConveyorUpgrades[conveyorLevel]
			local spawnMult = convUpgrade and convUpgrade.SpawnMultiplier or 1
			local interval = GameConfig.Conveyor.SpawnInterval * spawnMult

			spawnBox(player)
			task.wait(interval)
		end
	end)

	-- Box movement loop
	task.spawn(function()
		local lastTime = tick()
		while playerRunning[userId] do
			local now = tick()
			local dt = now - lastTime
			lastTime = now
			updateConveyor(player, dt)
			task.wait(0.05)  -- ~20 updates per second
		end
	end)
end

function ConveyorManager.StopConveyor(player: Player)
	local userId = player.UserId
	playerRunning[userId] = false

	-- Clean up all boxes
	if playerConveyors[userId] then
		for _, boxData in ipairs(playerConveyors[userId]) do
			local part = boxParts[boxData.Id]
			if part then
				part:Destroy()
				boxParts[boxData.Id] = nil
			end
		end
		playerConveyors[userId] = nil
	end
end

function ConveyorManager.TryBuyBox(player: Player, boxId: string)
	local userId = player.UserId
	if not playerConveyors[userId] then return end

	-- Find the box
	local targetBox = nil
	for _, boxData in ipairs(playerConveyors[userId]) do
		if boxData.Id == boxId then
			targetBox = boxData
			break
		end
	end

	if not targetBox then return end  -- box already gone

	-- Check if player can afford it
	if not DataManager.SpendMoney(player, targetBox.Price) then
		local notifEvent = RemoteSetup.GetEvent(RemoteNames.Events.ShowNotification)
		if notifEvent then
			notifEvent:FireClient(player, {
				Title = "Not enough money!",
				Text = "You need " .. Utils.FormatMoney(targetBox.Price) .. " to buy this box.",
				Color = Color3.fromRGB(255, 80, 80),
			})
		end
		return
	end

	-- Check base capacity
	local currentCount = DataManager.GetBrainrotCount(player)
	local maxCount = GameConfig.GetMaxBrainrots(DataManager.GetBaseLevel(player))
	if currentCount + targetBox.BrainrotCount > maxCount then
		-- Refund
		DataManager.AddMoney(player, targetBox.Price)
		local notifEvent = RemoteSetup.GetEvent(RemoteNames.Events.ShowNotification)
		if notifEvent then
			notifEvent:FireClient(player, {
				Title = "Base is full!",
				Text = "Upgrade your base to hold more Brainrots!",
				Color = Color3.fromRGB(255, 150, 50),
			})
		end
		return
	end

	-- Purchase successful - roll brainrots
	local brainrots = GameConfig.RollBrainrots(targetBox.Rarity, targetBox.BrainrotCount)

	-- Add brainrots to player
	local spawnedBrainrots = {}
	for _, brainrot in ipairs(brainrots) do
		local brainrotConfig = GameConfig.BrainrotsByName[brainrot.Name]
		local id = DataManager.AddBrainrot(player, brainrot)
		if id then
			table.insert(spawnedBrainrots, {
				Id = id,
				Name = brainrot.Name,
				Rarity = brainrot.Rarity,
				MoneyPerCycle = brainrot.MoneyPerCycle,
				ImageId = brainrotConfig and brainrotConfig.ImageId or "rbxassetid://0",
			})
		end
	end

	-- Remove box from belt
	removeBox(player, boxId, "purchased")
	
	-- TRIGGER LOOTBOX ANIMATION (non-blocking)
	task.spawn(function()
		local lootboxEvent = RemoteSetup.GetEvent(RemoteNames.Events.OpenLootbox)
		if lootboxEvent then
			lootboxEvent:FireClient(player, {
				BoxName = targetBox.BoxName,
				WonBrainrots = spawnedBrainrots,
			})
		end
		
		-- Wait for animation to complete before spawning visuals (7 seconds)
		task.wait(7)
		
		-- Spawn brainrot visuals in the base
		local spawnVisualEvent = RemoteSetup.GetEvent(RemoteNames.Events.SpawnBrainrotVisual)
		if spawnVisualEvent then
			for _, brainrot in ipairs(spawnedBrainrots) do
				spawnVisualEvent:FireClient(player, brainrot)
			end
		end
	end)

	-- Update client immediately (don't wait for animation)
	local moneyEvent = RemoteSetup.GetEvent(RemoteNames.Events.UpdateMoney)
	if moneyEvent then
		moneyEvent:FireClient(player, DataManager.GetMoney(player))
	end

	local brainrotEvent = RemoteSetup.GetEvent(RemoteNames.Events.UpdateBrainrots)
	if brainrotEvent then
		brainrotEvent:FireClient(player, DataManager.GetOwnedBrainrots(player))
	end

	-- Notify about purchase
	local purchaseEvent = RemoteSetup.GetEvent(RemoteNames.Events.BoxPurchased)
	if purchaseEvent then
		purchaseEvent:FireClient(player, {
			BoxName = targetBox.BoxName,
			Rarity = targetBox.Rarity,
			Brainrots = spawnedBrainrots,
		})
	end
end

return ConveyorManager
