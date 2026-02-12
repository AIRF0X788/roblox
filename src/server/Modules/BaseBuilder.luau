--[[
	BaseBuilder.luau
	Creates and manages each player's physical base in the workspace.
	The base contains:
	  - A platform (floor)
	  - A conveyor belt
	  - A brainrot display area
	  - Visual walls/boundaries
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)

local BaseBuilder = {}

-- Spacing between player bases
local BASE_SPACING = 120
local BASE_SIZE = Vector3.new(80, 1, 80)

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

	-- Calculate position (spread along X axis)
	local basePosition = Vector3.new((baseIndex - 1) * BASE_SPACING, 0, 0)

	-- Create the base model
	local baseModel = Instance.new("Model")
	baseModel.Name = "Base_" .. player.Name

	-- === FLOOR PLATFORM ===
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = BASE_SIZE
	floor.Position = basePosition + Vector3.new(0, -0.5, 0)
	floor.Anchored = true
	floor.BrickColor = BrickColor.new("Medium stone grey")
	floor.Material = Enum.Material.SmoothPlastic
	floor.TopSurface = Enum.SurfaceType.Smooth
	floor.BottomSurface = Enum.SurfaceType.Smooth
	floor.Parent = baseModel

	-- === SPAWN POINT ===
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnPoint"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Position = basePosition + Vector3.new(-25, 0.5, 25)
	spawn.Anchored = true
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
	beltBase.BrickColor = BrickColor.new("Dark stone grey")
	beltBase.Material = Enum.Material.DiamondPlate
	beltBase.TopSurface = Enum.SurfaceType.Smooth
	beltBase.Parent = baseModel

	-- Belt surface (the moving part visual - texture scroll)
	local beltSurface = Instance.new("Part")
	beltSurface.Name = "ConveyorSurface"
	beltSurface.Size = Vector3.new(conveyorConfig.BeltLength - 1, 0.2, conveyorConfig.BeltWidth - 0.5)
	beltSurface.Position = basePosition + Vector3.new(0, conveyorConfig.BeltHeight + 0.1, -15)
	beltSurface.Anchored = true
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
	local displayFloor = Instance.new("Part")
	displayFloor.Name = "BrainrotArea"
	displayFloor.Size = Vector3.new(50, 0.2, 30)
	displayFloor.Position = basePosition + Vector3.new(0, 0.1, 20)
	displayFloor.Anchored = true
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
