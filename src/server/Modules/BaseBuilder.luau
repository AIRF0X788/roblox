--[[
	BaseBuilder.luau
	Creates and manages each player's physical base in the workspace.
	The base contains:
	  - A platform (floor)
	  - A conveyor belt
	  - A brainrot display area
	  - Visual walls/boundaries
	
	UPDATED: Now supports up to 6 players with optimized layout (2 rows x 3 columns)
	FIXED: Z-fighting issues with floor textures by adjusting Y positions
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)

local BaseBuilder = {}

-- Spacing between player bases (optimized for 6 players)
local BASE_SPACING = 150
local BASE_SIZE = Vector3.new(80, 1, 80)
local MAX_PLAYERS = 6

-- Track which base index is assigned to which player
local baseAssignments = {} -- [userId] = index
local nextBaseIndex = 0

------------------------------------------------------------
-- BASE CREATION
------------------------------------------------------------

function BaseBuilder.CreateBase(player: Player): Model
	-- Assign a base index
	nextBaseIndex = nextBaseIndex + 1
	local baseIndex = nextBaseIndex
	baseAssignments[player.UserId] = baseIndex

	-- Calculate position (2 rows of 3 bases for 6 players)
	-- Row 0: bases 1, 2, 3 (indices 0, 1, 2)
	-- Row 1: bases 4, 5, 6 (indices 3, 4, 5)
	local row = math.floor((baseIndex - 1) / 3)
	local col = (baseIndex - 1) % 3
	local basePosition = Vector3.new(col * BASE_SPACING, 0, row * BASE_SPACING)

	-- Create the base model
	local baseModel = Instance.new("Model")
	baseModel.Name = "Base_" .. player.Name

	-- === FLOOR PLATFORM ===
	-- Fixed Y position to avoid z-fighting with terrain (raised to 0)
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = BASE_SIZE
	floor.Position = basePosition + Vector3.new(0, 0, 0)  -- Changed from -0.5 to 0
	floor.Anchored = true
	floor.CanCollide = true
	floor.BrickColor = BrickColor.new("Medium stone grey")
	floor.Material = Enum.Material.SmoothPlastic
	floor.TopSurface = Enum.SurfaceType.Smooth
	floor.BottomSurface = Enum.SurfaceType.Smooth
	floor.Parent = baseModel

	-- === SPAWN POINT ===
	-- Raised to prevent z-fighting
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnPoint"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Position = basePosition + Vector3.new(-25, 1, 25)  -- Changed from 0.5 to 1
	spawn.Anchored = true
	spawn.CanCollide = true
	spawn.BrickColor = BrickColor.new("Bright green")
	spawn.Material = Enum.Material.Neon
	spawn.TopSurface = Enum.SurfaceType.Smooth
	spawn.BottomSurface = Enum.SurfaceType.Smooth
	spawn.Neutral = false
	spawn.TeamColor = BrickColor.new("White")  -- will be set per player
	spawn.Parent = baseModel

	-- === CONVEYOR BELT ===
	local conveyorConfig = GameConfig.Conveyor
	local beltStart = basePosition + Vector3.new(-conveyorConfig.BeltLength / 2, conveyorConfig.BeltHeight, -15)

	-- Belt base (visual)
	local beltBase = Instance.new("Part")
	beltBase.Name = "ConveyorBase"
	beltBase.Size = Vector3.new(conveyorConfig.BeltLength, 0.5, conveyorConfig.BeltWidth)
	beltBase.Position = basePosition + Vector3.new(0, conveyorConfig.BeltHeight - 0.25, -15)
	beltBase.Anchored = true
	beltBase.CanCollide = true
	beltBase.BrickColor = BrickColor.new("Dark stone grey")
	beltBase.Material = Enum.Material.DiamondPlate
	beltBase.TopSurface = Enum.SurfaceType.Smooth
	beltBase.Parent = baseModel

	-- Belt surface (the moving part visual - texture scroll)
	-- Increased Y offset to prevent z-fighting with base
	local beltSurface = Instance.new("Part")
	beltSurface.Name = "ConveyorSurface"
	beltSurface.Size = Vector3.new(conveyorConfig.BeltLength - 1, 0.2, conveyorConfig.BeltWidth - 0.5)
	beltSurface.Position = basePosition + Vector3.new(0, conveyorConfig.BeltHeight + 0.3, -15)  -- Changed from 0.1 to 0.3
	beltSurface.Anchored = true
	beltSurface.CanCollide = false  -- No collision for surface decoration
	beltSurface.BrickColor = BrickColor.new("Black")
	beltSurface.Material = Enum.Material.Fabric
	beltSurface.TopSurface = Enum.SurfaceType.Smooth
	beltSurface.Parent = baseModel

	-- Texture to simulate movement
	local texture = Instance.new("Texture")
	texture.Name = "BeltTexture"
	texture.Texture = "rbxassetid://6372755229"
	texture.StudsPerTileU = 4
	texture.StudsPerTileV = 4
	texture.Face = Enum.NormalId.Top
	texture.Parent = beltSurface

	-- Side rails
	for _, side in ipairs({-1, 1}) do
		local rail = Instance.new("Part")
		rail.Name = "Rail"
		rail.Size = Vector3.new(conveyorConfig.BeltLength, 2, 0.5)
		rail.Position = basePosition + Vector3.new(0, conveyorConfig.BeltHeight + 1, -15 + side * (conveyorConfig.BeltWidth / 2 + 0.25))
		rail.Anchored = true
		rail.BrickColor = BrickColor.new("Bright orange")
		rail.Material = Enum.Material.Metal
		rail.Parent = baseModel
	end

	-- Start marker (where boxes spawn)
	local startMarker = Instance.new("Part")
	startMarker.Name = "ConveyorStart"
	startMarker.Size = Vector3.new(1, 3, conveyorConfig.BeltWidth + 2)
	startMarker.Position = basePosition + Vector3.new(-conveyorConfig.BeltLength / 2, conveyorConfig.BeltHeight + 1.5, -15)
	startMarker.Anchored = true
	startMarker.BrickColor = BrickColor.new("Bright green")
	startMarker.Material = Enum.Material.Neon
	startMarker.Transparency = 0.5
	startMarker.Parent = baseModel

	-- End marker (where boxes get destroyed)
	local endMarker = Instance.new("Part")
	endMarker.Name = "ConveyorEnd"
	endMarker.Size = Vector3.new(1, 3, conveyorConfig.BeltWidth + 2)
	endMarker.Position = basePosition + Vector3.new(conveyorConfig.BeltLength / 2, conveyorConfig.BeltHeight + 1.5, -15)
	endMarker.Anchored = true
	endMarker.BrickColor = BrickColor.new("Bright red")
	endMarker.Material = Enum.Material.Neon
	endMarker.Transparency = 0.5
	endMarker.Parent = baseModel

	-- === BRAINROT DISPLAY AREA ===
	-- Raised to prevent z-fighting with main floor
	local displayFloor = Instance.new("Part")
	displayFloor.Name = "BrainrotArea"
	displayFloor.Size = Vector3.new(50, 0.2, 30)
	displayFloor.Position = basePosition + Vector3.new(0, 0.6, 20)  -- Changed from 0.1 to 0.6
	displayFloor.Anchored = true
	displayFloor.CanCollide = false
	displayFloor.BrickColor = BrickColor.new("Institutional white")
	displayFloor.Material = Enum.Material.SmoothPlastic
	displayFloor.Transparency = 0.7
	displayFloor.Parent = baseModel

	-- Display area border
	for _, data in ipairs({
		{Size = Vector3.new(50, 1, 0.5), Offset = Vector3.new(0, 0.5, 15.25)},
		{Size = Vector3.new(50, 1, 0.5), Offset = Vector3.new(0, 0.5, -15.25 + 30)},  -- adjusted
		{Size = Vector3.new(0.5, 1, 30), Offset = Vector3.new(-25.25, 0.5, 20)},
		{Size = Vector3.new(0.5, 1, 30), Offset = Vector3.new(25.25, 0.5, 20)},
	}) do
		local border = Instance.new("Part")
		border.Name = "Border"
		border.Size = data.Size
		border.Position = basePosition + data.Offset
		border.Anchored = true
		border.BrickColor = BrickColor.new("Bright blue")
		border.Material = Enum.Material.Neon
		border.Transparency = 0.3
		border.Parent = baseModel
	end

	-- === PLAYER NAME SIGN ===
	local signPart = Instance.new("Part")
	signPart.Name = "NameSign"
	signPart.Size = Vector3.new(20, 5, 0.5)
	signPart.Position = basePosition + Vector3.new(0, 8, -35)
	signPart.Anchored = true
	signPart.BrickColor = BrickColor.new("Really black")
	signPart.Material = Enum.Material.SmoothPlastic
	signPart.Parent = baseModel

	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "SignGui"
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.Parent = signPart

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "PlayerName"
	nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.Text = player.Name .. "'s Base"
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = surfaceGui

	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "LevelText"
	levelLabel.Size = UDim2.new(1, 0, 0.4, 0)
	levelLabel.Position = UDim2.new(0, 0, 0.6, 0)
	levelLabel.Text = "Level 1"
	levelLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
	levelLabel.TextScaled = true
	levelLabel.BackgroundTransparency = 1
	levelLabel.Font = Enum.Font.GothamBold
	levelLabel.Parent = surfaceGui
	
	-- === MONEY COLLECTOR ===
	-- Platform where players click to collect money from their brainrots
	local collectorPlatform = Instance.new("Part")
	collectorPlatform.Name = "MoneyCollector"
	collectorPlatform.Size = Vector3.new(8, 1, 8)
	collectorPlatform.Position = basePosition + Vector3.new(25, 0.5, 25)
	collectorPlatform.Anchored = true
	collectorPlatform.CanCollide = true
	collectorPlatform.BrickColor = BrickColor.new("Bright yellow")
	collectorPlatform.Material = Enum.Material.Neon
	collectorPlatform.TopSurface = Enum.SurfaceType.Smooth
	collectorPlatform.Parent = baseModel
	
	-- Collector sign
	local collectorSign = Instance.new("Part")
	collectorSign.Name = "CollectorSign"
	collectorSign.Size = Vector3.new(8, 4, 0.5)
	collectorSign.Position = basePosition + Vector3.new(25, 4, 25)
	collectorSign.Anchored = true
	collectorSign.CanCollide = false
	collectorSign.BrickColor = BrickColor.new("Really black")
	collectorSign.Material = Enum.Material.SmoothPlastic
	collectorSign.Parent = baseModel
	
	local collectorGui = Instance.new("SurfaceGui")
	collectorGui.Face = Enum.NormalId.Front
	collectorGui.Parent = collectorSign
	
	local collectorTitle = Instance.new("TextLabel")
	collectorTitle.Size = UDim2.new(1, 0, 0.5, 0)
	collectorTitle.Text = "💰 MONEY COLLECTOR"
	collectorTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
	collectorTitle.TextScaled = true
	collectorTitle.BackgroundTransparency = 1
	collectorTitle.Font = Enum.Font.GothamBold
	collectorTitle.Parent = collectorGui
	
	local collectorInfo = Instance.new("TextLabel")
	collectorInfo.Name = "PendingMoneyLabel"
	collectorInfo.Size = UDim2.new(1, 0, 0.5, 0)
	collectorInfo.Position = UDim2.new(0, 0, 0.5, 0)
	collectorInfo.Text = "Click to collect: $0"
	collectorInfo.TextColor3 = Color3.fromRGB(100, 255, 100)
	collectorInfo.TextScaled = true
	collectorInfo.BackgroundTransparency = 1
	collectorInfo.Font = Enum.Font.Gotham
	collectorInfo.Parent = collectorGui
	
	-- Click detector for collection
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 20
	clickDetector.Parent = collectorPlatform

	-- Set primary part and parent
	baseModel.PrimaryPart = floor
	baseModel.Parent = game.Workspace.Bases

	return baseModel
end

------------------------------------------------------------
-- GETTERS
------------------------------------------------------------

function BaseBuilder.GetBase(player: Player): Model?
	return game.Workspace.Bases:FindFirstChild("Base_" .. player.Name)
end

function BaseBuilder.GetConveyorStart(player: Player): Vector3?
	local base = BaseBuilder.GetBase(player)
	if base then
		local startMarker = base:FindFirstChild("ConveyorStart")
		if startMarker then
			return startMarker.Position
		end
	end
	return nil
end

function BaseBuilder.GetConveyorEnd(player: Player): Vector3?
	local base = BaseBuilder.GetBase(player)
	if base then
		local endMarker = base:FindFirstChild("ConveyorEnd")
		if endMarker then
			return endMarker.Position
		end
	end
	return nil
end

function BaseBuilder.GetBrainrotAreaCenter(player: Player): Vector3?
	local base = BaseBuilder.GetBase(player)
	if base then
		local area = base:FindFirstChild("BrainrotArea")
		if area then
			return area.Position + Vector3.new(0, 1, 0)
		end
	end
	return nil
end

function BaseBuilder.GetMoneyCollector(player: Player): Part?
	local base = BaseBuilder.GetBase(player)
	if base then
		return base:FindFirstChild("MoneyCollector")
	end
	return nil
end

function BaseBuilder.UpdatePendingMoney(player: Player, amount: number)
	local base = BaseBuilder.GetBase(player)
	if base then
		local sign = base:FindFirstChild("CollectorSign")
		if sign then
			local gui = sign:FindFirstChild("SurfaceGui")
			if gui then
				local label = gui:FindFirstChild("PendingMoneyLabel")
				if label then
					label.Text = "Click to collect: $" .. tostring(amount)
				end
			end
		end
	end
end

function BaseBuilder.UpdateLevelSign(player: Player, level: number)
	local base = BaseBuilder.GetBase(player)
	if base then
		local sign = base:FindFirstChild("NameSign")
		if sign then
			local gui = sign:FindFirstChild("SignGui")
			if gui then
				local levelText = gui:FindFirstChild("LevelText")
				if levelText then
					levelText.Text = "Level " .. tostring(level)
				end
			end
		end
	end
end

------------------------------------------------------------
-- CLEANUP
------------------------------------------------------------

function BaseBuilder.DestroyBase(player: Player)
	local base = BaseBuilder.GetBase(player)
	if base then
		base:Destroy()
	end
	baseAssignments[player.UserId] = nil
end

return BaseBuilder
