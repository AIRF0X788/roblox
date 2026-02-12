--[[
	BrainrotManager.luau
	Manages brainrot visual spawning in the player's base
	and handles the money collection cycle.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)
local RemoteNames = require(ReplicatedStorage.Shared.Modules.RemoteNames)
local Utils = require(ReplicatedStorage.Shared.Modules.Utils)
local RemoteSetup = require(script.Parent.RemoteSetup)
local DataManager = require(script.Parent.DataManager)
local BaseBuilder = require(script.Parent.BaseBuilder)

local BrainrotManager = {}

-- Visual brainrot parts in workspace: [brainrotId] = Part
local brainrotParts = {}

-- Running state for money collection
local collectionRunning = {}

------------------------------------------------------------
-- BRAINROT VISUAL CREATION
------------------------------------------------------------

function BrainrotManager.CreateBrainrotVisual(player: Player, brainrotData)
	local areaCenter = BaseBuilder.GetBrainrotAreaCenter(player)
	if not areaCenter then return end

	local rarityData = GameConfig.Rarities[brainrotData.Rarity]
	if not rarityData then return end

	-- Randomize position within the brainrot area
	local offsetX = math.random(-20, 20)
	local offsetZ = math.random(-12, 12)
	local position = areaCenter + Vector3.new(offsetX, 0, offsetZ)

	-- Create the brainrot visual (a simple humanoid-ish shape)
	local model = Instance.new("Model")
	model.Name = "Brainrot_" .. brainrotData.Id

	-- Body
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2, 2, 2)
	body.Position = position
	body.Anchored = true
	body.CanCollide = false
	body.Shape = Enum.PartType.Ball
	body.Color = rarityData.Color
	body.Material = Enum.Material.SmoothPlastic
	body.Parent = model

	-- Glow for higher rarities
	if rarityData.GlowIntensity > 0 then
		local light = Instance.new("PointLight")
		light.Color = rarityData.Color
		light.Brightness = rarityData.GlowIntensity * 1.5
		light.Range = 6 + rarityData.GlowIntensity * 4
		light.Parent = body
	end

	-- Name billboard
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 160, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = false
	billboard.Parent = body

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
	nameLabel.Text = brainrotData.Name
	nameLabel.TextColor3 = rarityData.Color
	nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	nameLabel.TextStrokeTransparency = 0.3
	nameLabel.TextScaled = true
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = billboard

	local moneyLabel = Instance.new("TextLabel")
	moneyLabel.Name = "MoneyLabel"
	moneyLabel.Size = UDim2.new(1, 0, 0.4, 0)
	moneyLabel.Position = UDim2.new(0, 0, 0.6, 0)
	moneyLabel.Text = "+" .. Utils.FormatMoney(brainrotData.MoneyPerCycle) .. "/cycle"
	moneyLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	moneyLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	moneyLabel.TextStrokeTransparency = 0.3
	moneyLabel.TextScaled = true
	moneyLabel.BackgroundTransparency = 1
	moneyLabel.Font = Enum.Font.Gotham
	moneyLabel.Parent = billboard

	-- Idle animation: gentle bobbing
	task.spawn(function()
		local startY = position.Y
		local phase = math.random() * math.pi * 2
		while body and body.Parent do
			local t = tick() * 2 + phase
			body.Position = Vector3.new(position.X, startY + math.sin(t) * 0.3, position.Z)
			body.Orientation = Vector3.new(0, (t * 30) % 360, 0)
			task.wait(0.05)
		end
	end)

	model.PrimaryPart = body
	model.Parent = game.Workspace.Brainrots

	brainrotParts[brainrotData.Id] = model
end

function BrainrotManager.RemoveBrainrotVisual(brainrotId: string)
	local model = brainrotParts[brainrotId]
	if model then
		model:Destroy()
		brainrotParts[brainrotId] = nil
	end
end

------------------------------------------------------------
-- SPAWN ALL BRAINROTS (when player joins or loads data)
------------------------------------------------------------

function BrainrotManager.SpawnAllBrainrots(player: Player)
	local brainrots = DataManager.GetOwnedBrainrots(player)
	for _, brainrot in ipairs(brainrots) do
		BrainrotManager.CreateBrainrotVisual(player, brainrot)
	end
end

function BrainrotManager.ClearAllBrainrots(player: Player)
	local brainrots = DataManager.GetOwnedBrainrots(player)
	for _, brainrot in ipairs(brainrots) do
		BrainrotManager.RemoveBrainrotVisual(brainrot.Id)
	end
end

------------------------------------------------------------
-- SELL BRAINROT
------------------------------------------------------------

function BrainrotManager.SellBrainrot(player: Player, brainrotId: string)
	local brainrots = DataManager.GetOwnedBrainrots(player)
	local targetBrainrot = nil
	for _, b in ipairs(brainrots) do
		if b.Id == brainrotId then
			targetBrainrot = b
			break
		end
	end

	if not targetBrainrot then return end

	-- Sell value = 5x the money per cycle
	local sellValue = targetBrainrot.MoneyPerCycle * 5

	-- Remove from data and visual
	DataManager.RemoveBrainrot(player, brainrotId)
	BrainrotManager.RemoveBrainrotVisual(brainrotId)

	-- Give money
	DataManager.AddMoney(player, sellValue)

	-- Update client
	local moneyEvent = RemoteSetup.GetEvent(RemoteNames.Events.UpdateMoney)
	if moneyEvent then
		moneyEvent:FireClient(player, DataManager.GetMoney(player))
	end

	local brainrotEvent = RemoteSetup.GetEvent(RemoteNames.Events.UpdateBrainrots)
	if brainrotEvent then
		brainrotEvent:FireClient(player, DataManager.GetOwnedBrainrots(player))
	end

	local notifEvent = RemoteSetup.GetEvent(RemoteNames.Events.ShowNotification)
	if notifEvent then
		notifEvent:FireClient(player, {
			Title = "Sold!",
			Text = targetBrainrot.Name .. " sold for " .. Utils.FormatMoney(sellValue),
			Color = Color3.fromRGB(100, 255, 100),
		})
	end
end

------------------------------------------------------------
-- MONEY COLLECTION CYCLE
------------------------------------------------------------

function BrainrotManager.StartMoneyCollection(player: Player)
	local userId = player.UserId
	collectionRunning[userId] = true

	task.spawn(function()
		while collectionRunning[userId] do
			task.wait(GameConfig.MoneyCollectionInterval)

			if not collectionRunning[userId] then break end

			local income = DataManager.GetIncomePerCycle(player)
			if income > 0 then
				DataManager.AddMoney(player, income)

				-- Update client money
				local moneyEvent = RemoteSetup.GetEvent(RemoteNames.Events.UpdateMoney)
				if moneyEvent then
					moneyEvent:FireClient(player, DataManager.GetMoney(player))
				end
			end
		end
	end)
end

function BrainrotManager.StopMoneyCollection(player: Player)
	collectionRunning[player.UserId] = false
end

return BrainrotManager
