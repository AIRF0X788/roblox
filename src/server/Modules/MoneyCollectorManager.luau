--[[
	MoneyCollectorManager.luau
	Manages manual money collection system for each player's base.
	Players must click the Money Collector platform to collect pending income.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)
local RemoteNames = require(ReplicatedStorage.Shared.Modules.RemoteNames)
local Utils = require(ReplicatedStorage.Shared.Modules.Utils)
local RemoteSetup = require(script.Parent.RemoteSetup)
local DataManager = require(script.Parent.DataManager)
local BaseBuilder = require(script.Parent.BaseBuilder)

local MoneyCollectorManager = {}

-- Pending money for each player: [userId] = amount
local pendingMoney = {}

-- Money collection cycle state
local collectionRunning = {}

-- Visual money collector parts: [userId] = model
local collectorParts = {}

------------------------------------------------------------
-- CREATE MONEY COLLECTOR IN BASE
------------------------------------------------------------

function MoneyCollectorManager.CreateCollector(player: Player)
	local baseModel = BaseBuilder.GetBaseModel(player)
	if not baseModel then
		warn("[MoneyCollectorManager] Base not found for player:", player.Name)
		return
	end
	
	local floor = baseModel:FindFirstChild("Floor")
	if not floor then return end
	
	-- Position: In front of the base, near the conveyor
	local basePosition = floor.Position
	local collectorPosition = basePosition + Vector3.new(-30, 2, 0)
	
	-- Create collector model
	local model = Instance.new("Model")
	model.Name = "MoneyCollector"
	
	-- Main platform (glowing)
	local platform = Instance.new("Part")
	platform.Name = "CollectorPlatform"
	platform.Size = Vector3.new(8, 1, 8)
	platform.Position = collectorPosition
	platform.Anchored = true
	platform.CanCollide = false
	platform.Material = Enum.Material.Neon
	platform.Color = Color3.fromRGB(255, 215, 0)  -- Gold color
	platform.Transparency = 0.3
	platform.Parent = model
	
	-- Add glow effect
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 215, 0)
	light.Brightness = 2
	light.Range = 15
	light.Parent = platform
	
	-- Rotating top (coin stack effect)
	local coinTop = Instance.new("Part")
	coinTop.Name = "CoinTop"
	coinTop.Size = Vector3.new(4, 0.5, 4)
	coinTop.Position = collectorPosition + Vector3.new(0, 1, 0)
	coinTop.Anchored = true
	coinTop.CanCollide = false
	coinTop.Shape = Enum.PartType.Cylinder
	coinTop.Material = Enum.Material.SmoothPlastic
	coinTop.Color = Color3.fromRGB(255, 200, 50)
	coinTop.Orientation = Vector3.new(0, 0, 90)
	coinTop.Parent = model
	
	-- Billboard GUI showing pending money
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PendingMoneyBillboard"
	billboard.Size = UDim2.new(0, 200, 0, 100)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = platform
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.Parent = billboard
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	titleLabel.Text = "💰 PENDING MONEY"
	titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	titleLabel.TextStrokeTransparency = 0.5
	titleLabel.TextScaled = true
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = frame
	
	local amountLabel = Instance.new("TextLabel")
	amountLabel.Name = "Amount"
	amountLabel.Size = UDim2.new(1, -10, 0.4, 0)
	amountLabel.Position = UDim2.new(0, 5, 0.4, 0)
	amountLabel.Text = "$0"
	amountLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	amountLabel.TextStrokeTransparency = 0.5
	amountLabel.TextScaled = true
	amountLabel.BackgroundTransparency = 1
	amountLabel.Font = Enum.Font.GothamBold
	amountLabel.Parent = frame
	
	local instructionLabel = Instance.new("TextLabel")
	instructionLabel.Name = "Instruction"
	instructionLabel.Size = UDim2.new(1, 0, 0.2, 0)
	instructionLabel.Position = UDim2.new(0, 0, 0.8, 0)
	instructionLabel.Text = "Click to collect!"
	instructionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	instructionLabel.TextStrokeTransparency = 0.7
	instructionLabel.TextScaled = true
	instructionLabel.BackgroundTransparency = 1
	instructionLabel.Font = Enum.Font.Gotham
	instructionLabel.Parent = frame
	
	-- ClickDetector for collection
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 20
	clickDetector.Parent = platform
	
	clickDetector.MouseClick:Connect(function(clickingPlayer)
		if clickingPlayer == player then
			MoneyCollectorManager.CollectMoney(player)
		end
	end)
	
	-- Idle animation: gentle pulsing and rotation
	task.spawn(function()
		local phase = math.random() * math.pi * 2
		while platform and platform.Parent do
			local t = tick() * 2 + phase
			
			-- Pulse transparency
			platform.Transparency = 0.3 + math.sin(t) * 0.1
			
			-- Rotate coin top
			if coinTop and coinTop.Parent then
				local currentOrientation = coinTop.Orientation
				coinTop.Orientation = Vector3.new(currentOrientation.X, currentOrientation.Y + 2, currentOrientation.Z)
			end
			
			task.wait(0.05)
		end
	end)
	
	model.PrimaryPart = platform
	model.Parent = baseModel
	
	collectorParts[player.UserId] = model
	
	-- Initialize pending money
	pendingMoney[player.UserId] = 0
	
	print("[MoneyCollectorManager] Created collector for:", player.Name)
end

function MoneyCollectorManager.RemoveCollector(player: Player)
	local model = collectorParts[player.UserId]
	if model then
		model:Destroy()
		collectorParts[player.UserId] = nil
	end
	
	pendingMoney[player.UserId] = nil
end

------------------------------------------------------------
-- UPDATE PENDING MONEY DISPLAY
------------------------------------------------------------

function MoneyCollectorManager.UpdateDisplay(player: Player)
	local model = collectorParts[player.UserId]
	if not model then return end
	
	local platform = model:FindFirstChild("CollectorPlatform")
	if not platform then return end
	
	local billboard = platform:FindFirstChild("PendingMoneyBillboard")
	if not billboard then return end
	
	local frame = billboard:FindFirstChild("Frame")
	if not frame then return end
	
	local amountLabel = frame:FindFirstChild("Amount")
	if not amountLabel then return end
	
	local pending = pendingMoney[player.UserId] or 0
	amountLabel.Text = Utils.FormatMoney(pending)
	
	-- Change color based on amount
	if pending >= 1000 then
		amountLabel.TextColor3 = Color3.fromRGB(255, 215, 0)  -- Gold for large amounts
	elseif pending >= 100 then
		amountLabel.TextColor3 = Color3.fromRGB(100, 255, 100)  -- Green
	else
		amountLabel.TextColor3 = Color3.fromRGB(150, 150, 150)  -- Gray for small amounts
	end
end

------------------------------------------------------------
-- COLLECT MONEY (MANUAL)
------------------------------------------------------------

function MoneyCollectorManager.CollectMoney(player: Player)
	local pending = pendingMoney[player.UserId] or 0
	
	if pending <= 0 then
		-- Show notification
		local notifEvent = RemoteSetup.GetEvent(RemoteNames.Events.ShowNotification)
		if notifEvent then
			notifEvent:FireClient(player, {
				Title = "No Money",
				Text = "No pending money to collect!",
				Color = Color3.fromRGB(200, 200, 200),
			})
		end
		return
	end
	
	-- Add to player's money
	DataManager.AddMoney(player, pending)
	
	-- Reset pending
	pendingMoney[player.UserId] = 0
	MoneyCollectorManager.UpdateDisplay(player)
	
	-- Update client money
	local moneyEvent = RemoteSetup.GetEvent(RemoteNames.Events.UpdateMoney)
	if moneyEvent then
		moneyEvent:FireClient(player, DataManager.GetMoney(player))
	end
	
	-- Show notification
	local notifEvent = RemoteSetup.GetEvent(RemoteNames.Events.ShowNotification)
	if notifEvent then
		notifEvent:FireClient(player, {
			Title = "Money Collected!",
			Text = "+" .. Utils.FormatMoney(pending),
			Color = Color3.fromRGB(100, 255, 100),
		})
	end
	
	-- Play visual effect (enlarge coin briefly)
	local model = collectorParts[player.UserId]
	if model then
		local coinTop = model:FindFirstChild("CoinTop")
		if coinTop then
			local originalSize = coinTop.Size
			coinTop.Size = originalSize * 1.2
			task.wait(0.1)
			coinTop.Size = originalSize
		end
	end
	
	print("[MoneyCollectorManager] Player", player.Name, "collected", Utils.FormatMoney(pending))
end

------------------------------------------------------------
-- PASSIVE INCOME ACCUMULATION CYCLE
------------------------------------------------------------

function MoneyCollectorManager.StartIncomeAccumulation(player: Player)
	local userId = player.UserId
	collectionRunning[userId] = true
	
	task.spawn(function()
		while collectionRunning[userId] do
			task.wait(GameConfig.MoneyCollectionInterval)
			
			if not collectionRunning[userId] then break end
			
			-- Calculate income from all brainrots
			local income = DataManager.GetIncomePerCycle(player)
			if income > 0 then
				-- Add to pending (not directly to player)
				pendingMoney[userId] = (pendingMoney[userId] or 0) + income
				MoneyCollectorManager.UpdateDisplay(player)
			end
		end
	end)
end

function MoneyCollectorManager.StopIncomeAccumulation(player: Player)
	collectionRunning[player.UserId] = false
end

return MoneyCollectorManager
