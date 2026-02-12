--[[
	MapBuilder.luau
	Creates the game world/map with boundaries to prevent players from falling.
	Includes:
	  - Main platform/ground
	  - Invisible barriers around the map
	  - Decorative elements
	  - Spawn safe zones
	  - Support for 6 player bases in a 2x3 grid layout
]]

local MapBuilder = {}

-- Map dimensions
local BASE_SPACING = 150  -- Must match BaseBuilder spacing
local ROWS = 2
local COLS = 3
local MAP_PADDING = 100   -- Extra space around bases
local BARRIER_HEIGHT = 100 -- Height of invisible walls

-- Calculate total map size based on base layout
local MAP_WIDTH = (COLS * BASE_SPACING) + (MAP_PADDING * 2)
local MAP_DEPTH = (ROWS * BASE_SPACING) + (MAP_PADDING * 2)

------------------------------------------------------------
-- MAIN MAP CREATION
------------------------------------------------------------

function MapBuilder.CreateMap(): Model
	local mapModel = Instance.new("Model")
	mapModel.Name = "GameMap"
	
	-- Create main ground platform
	local ground = Instance.new("Part")
	ground.Name = "GroundPlatform"
	ground.Size = Vector3.new(MAP_WIDTH, 2, MAP_DEPTH)
	ground.Position = Vector3.new((MAP_WIDTH / 2) - MAP_PADDING, -2, (MAP_DEPTH / 2) - MAP_PADDING)
	ground.Anchored = true
	ground.CanCollide = true
	ground.BrickColor = BrickColor.new("Dark green")
	ground.Material = Enum.Material.Grass
	ground.TopSurface = Enum.SurfaceType.Smooth
	ground.BottomSurface = Enum.SurfaceType.Smooth
	ground.Parent = mapModel
	
	-- Add some texture variety
	local texture = Instance.new("Texture")
	texture.Texture = "rbxasset://textures/terrain/grass.png"
	texture.StudsPerTileU = 20
	texture.StudsPerTileV = 20
	texture.Face = Enum.NormalId.Top
	texture.Parent = ground
	
	-- Create border platform (slightly lower) for visual effect
	local border = Instance.new("Part")
	border.Name = "BorderPlatform"
	border.Size = Vector3.new(MAP_WIDTH + 40, 1, MAP_DEPTH + 40)
	border.Position = Vector3.new((MAP_WIDTH / 2) - MAP_PADDING, -3.5, (MAP_DEPTH / 2) - MAP_PADDING)
	border.Anchored = true
	border.CanCollide = true
	border.BrickColor = BrickColor.new("Earth green")
	border.Material = Enum.Material.Slate
	border.TopSurface = Enum.SurfaceType.Smooth
	border.Parent = mapModel
	
	print("[MapBuilder] Main platform created: " .. MAP_WIDTH .. " x " .. MAP_DEPTH .. " studs")
	
	return mapModel
end

------------------------------------------------------------
-- BARRIER CREATION (Invisible walls)
------------------------------------------------------------

function MapBuilder.CreateBarriers(mapModel: Model)
	-- Barrier positions (North, South, East, West)
	local barriers = {
		-- North wall
		{
			Name = "NorthBarrier",
			Size = Vector3.new(MAP_WIDTH + 60, BARRIER_HEIGHT, 5),
			Position = Vector3.new((MAP_WIDTH / 2) - MAP_PADDING, BARRIER_HEIGHT / 2 - 3, -MAP_PADDING - 30),
		},
		-- South wall
		{
			Name = "SouthBarrier",
			Size = Vector3.new(MAP_WIDTH + 60, BARRIER_HEIGHT, 5),
			Position = Vector3.new((MAP_WIDTH / 2) - MAP_PADDING, BARRIER_HEIGHT / 2 - 3, MAP_DEPTH - MAP_PADDING + 30),
		},
		-- East wall
		{
			Name = "EastBarrier",
			Size = Vector3.new(5, BARRIER_HEIGHT, MAP_DEPTH + 60),
			Position = Vector3.new(MAP_WIDTH - MAP_PADDING + 30, BARRIER_HEIGHT / 2 - 3, (MAP_DEPTH / 2) - MAP_PADDING),
		},
		-- West wall
		{
			Name = "WestBarrier",
			Size = Vector3.new(5, BARRIER_HEIGHT, MAP_DEPTH + 60),
			Position = Vector3.new(-MAP_PADDING - 30, BARRIER_HEIGHT / 2 - 3, (MAP_DEPTH / 2) - MAP_PADDING),
		},
	}
	
	for _, barrierData in ipairs(barriers) do
		local barrier = Instance.new("Part")
		barrier.Name = barrierData.Name
		barrier.Size = barrierData.Size
		barrier.Position = barrierData.Position
		barrier.Anchored = true
		barrier.CanCollide = true
		barrier.Transparency = 0.85  -- Almost invisible but slightly visible
		barrier.BrickColor = BrickColor.new("Electric blue")
		barrier.Material = Enum.Material.ForceField
		barrier.TopSurface = Enum.SurfaceType.Smooth
		barrier.BottomSurface = Enum.SurfaceType.Smooth
		barrier.Parent = mapModel
		
		-- Add glow effect
		local light = Instance.new("SurfaceLight")
		light.Face = Enum.NormalId.Front
		light.Color = Color3.fromRGB(0, 170, 255)
		light.Brightness = 0.5
		light.Range = 30
		light.Parent = barrier
	end
	
	print("[MapBuilder] Barriers created (4 walls)")
end

------------------------------------------------------------
-- DECORATIVE ELEMENTS
------------------------------------------------------------

function MapBuilder.AddDecorations(mapModel: Model)
	-- Corner pillars
	local cornerPositions = {
		Vector3.new(-MAP_PADDING, 5, -MAP_PADDING),
		Vector3.new(MAP_WIDTH - MAP_PADDING, 5, -MAP_PADDING),
		Vector3.new(-MAP_PADDING, 5, MAP_DEPTH - MAP_PADDING),
		Vector3.new(MAP_WIDTH - MAP_PADDING, 5, MAP_DEPTH - MAP_PADDING),
	}
	
	for i, pos in ipairs(cornerPositions) do
		local pillar = Instance.new("Part")
		pillar.Name = "CornerPillar_" .. i
		pillar.Size = Vector3.new(8, 20, 8)
		pillar.Position = pos
		pillar.Anchored = true
		pillar.CanCollide = false
		pillar.BrickColor = BrickColor.new("Really black")
		pillar.Material = Enum.Material.Metal
		pillar.Parent = mapModel
		
		-- Top decoration
		local top = Instance.new("Part")
		top.Name = "PillarTop"
		top.Size = Vector3.new(10, 2, 10)
		top.Position = pos + Vector3.new(0, 11, 0)
		top.Anchored = true
		top.CanCollide = false
		top.BrickColor = BrickColor.new("Gold")
		top.Material = Enum.Material.Neon
		top.Parent = mapModel
		
		-- Light on top
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 200, 50)
		light.Brightness = 2
		light.Range = 60
		light.Parent = top
	end
	
	-- Center spawn platform (decorative)
	local centerX = (MAP_WIDTH / 2) - MAP_PADDING
	local centerZ = (MAP_DEPTH / 2) - MAP_PADDING
	
	local spawnPlatform = Instance.new("Part")
	spawnPlatform.Name = "CenterSpawnPlatform"
	spawnPlatform.Size = Vector3.new(30, 1, 30)
	spawnPlatform.Position = Vector3.new(centerX, 0.5, centerZ)
	spawnPlatform.Anchored = true
	spawnPlatform.CanCollide = true
	spawnPlatform.BrickColor = BrickColor.new("Dark stone grey")
	spawnPlatform.Material = Enum.Material.Cobblestone
	spawnPlatform.Parent = mapModel
	
	-- Welcome sign
	local signPart = Instance.new("Part")
	signPart.Name = "WelcomeSign"
	signPart.Size = Vector3.new(25, 10, 1)
	signPart.Position = Vector3.new(centerX, 12, -MAP_PADDING + 40)
	signPart.Anchored = true
	signPart.CanCollide = false
	signPart.BrickColor = BrickColor.new("Really black")
	signPart.Material = Enum.Material.SmoothPlastic
	signPart.Parent = mapModel
	
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.Parent = signPart
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0.5, 0)
	titleLabel.Position = UDim2.new(0, 0, 0.1, 0)
	titleLabel.Text = "🧠 BRAINROT BOXES 🧠"
	titleLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
	titleLabel.TextScaled = true
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = surfaceGui
	
	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Size = UDim2.new(1, 0, 0.3, 0)
	subtitleLabel.Position = UDim2.new(0, 0, 0.6, 0)
	subtitleLabel.Text = "Collect. Upgrade. Dominate."
	subtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	subtitleLabel.TextScaled = true
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.Parent = surfaceGui
	
	print("[MapBuilder] Decorations added")
end

------------------------------------------------------------
-- LIGHTING SETUP
------------------------------------------------------------

function MapBuilder.ConfigureLighting()
	local lighting = game:GetService("Lighting")
	
	-- Set time of day and atmosphere
	lighting.TimeOfDay = "14:00:00"  -- Afternoon
	lighting.Brightness = 2
	lighting.Ambient = Color3.fromRGB(140, 140, 140)
	lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
	
	-- Add atmosphere for better visuals
	if not lighting:FindFirstChild("Atmosphere") then
		local atmosphere = Instance.new("Atmosphere")
		atmosphere.Density = 0.3
		atmosphere.Offset = 0.25
		atmosphere.Color = Color3.fromRGB(199, 199, 199)
		atmosphere.Decay = Color3.fromRGB(106, 112, 125)
		atmosphere.Glare = 0.3
		atmosphere.Haze = 1
		atmosphere.Parent = lighting
	end
	
	-- Add bloom effect
	if not lighting:FindFirstChild("Bloom") then
		local bloom = Instance.new("BloomEffect")
		bloom.Intensity = 0.4
		bloom.Size = 24
		bloom.Threshold = 0.8
		bloom.Parent = lighting
	end
	
	-- Add color correction for better visuals
	if not lighting:FindFirstChild("ColorCorrection") then
		local colorCorrection = Instance.new("ColorCorrectionEffect")
		colorCorrection.Brightness = 0.05
		colorCorrection.Contrast = 0.1
		colorCorrection.Saturation = 0.2
		colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
		colorCorrection.Parent = lighting
	end
	
	print("[MapBuilder] Lighting configured")
end

------------------------------------------------------------
-- BASE ZONE MARKERS (Optional visual guides)
------------------------------------------------------------

function MapBuilder.CreateBaseZoneMarkers(mapModel: Model)
	-- Create subtle zone markers for each of the 6 base positions
	for row = 0, ROWS - 1 do
		for col = 0, COLS - 1 do
			local baseNum = (row * COLS) + col + 1
			local posX = col * BASE_SPACING
			local posZ = row * BASE_SPACING
			
			-- Zone outline
			local zoneBorder = Instance.new("Part")
			zoneBorder.Name = "BaseZone_" .. baseNum
			zoneBorder.Size = Vector3.new(BASE_SPACING - 20, 0.1, BASE_SPACING - 20)
			zoneBorder.Position = Vector3.new(posX, 0.05, posZ)
			zoneBorder.Anchored = true
			zoneBorder.CanCollide = false
			zoneBorder.Transparency = 0.95
			zoneBorder.BrickColor = BrickColor.new("Bright blue")
			zoneBorder.Material = Enum.Material.Neon
			zoneBorder.Parent = mapModel
			
			-- Zone number label (on ground)
			local numberPart = Instance.new("Part")
			numberPart.Name = "ZoneNumber"
			numberPart.Size = Vector3.new(10, 0.2, 10)
			numberPart.Position = Vector3.new(posX - 30, 0.1, posZ - 30)
			numberPart.Anchored = true
			numberPart.CanCollide = false
			numberPart.BrickColor = BrickColor.new("Really black")
			numberPart.Material = Enum.Material.SmoothPlastic
			numberPart.Parent = mapModel
			
			local surfaceGui = Instance.new("SurfaceGui")
			surfaceGui.Face = Enum.NormalId.Top
			surfaceGui.Parent = numberPart
			
			local numberLabel = Instance.new("TextLabel")
			numberLabel.Size = UDim2.new(1, 0, 1, 0)
			numberLabel.Text = "Zone " .. baseNum
			numberLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			numberLabel.TextScaled = true
			numberLabel.BackgroundTransparency = 1
			numberLabel.Font = Enum.Font.GothamBold
			numberLabel.Parent = surfaceGui
		end
	end
	
	print("[MapBuilder] Base zone markers created (6 zones)")
end

------------------------------------------------------------
-- KILL ZONE (Safety net if player somehow falls through)
------------------------------------------------------------

function MapBuilder.CreateKillZone(mapModel: Model)
	local killZone = Instance.new("Part")
	killZone.Name = "KillZone"
	killZone.Size = Vector3.new(MAP_WIDTH + 200, 10, MAP_DEPTH + 200)
	killZone.Position = Vector3.new((MAP_WIDTH / 2) - MAP_PADDING, -100, (MAP_DEPTH / 2) - MAP_PADDING)
	killZone.Anchored = true
	killZone.CanCollide = false
	killZone.Transparency = 1
	killZone.Parent = mapModel
	
	-- Kill zone touch event (respawn player)
	killZone.Touched:Connect(function(hit)
		local character = hit.Parent
		if character and character:FindFirstChild("Humanoid") then
			local humanoid = character.Humanoid
			if humanoid.Health > 0 then
				-- Respawn the player by killing them (Roblox auto-respawn)
				humanoid.Health = 0
				warn("[MapBuilder] Player " .. character.Name .. " fell out of bounds and was respawned")
			end
		end
	end)
	
	print("[MapBuilder] Kill zone created (safety net)")
end

------------------------------------------------------------
-- INITIALIZE FULL MAP
------------------------------------------------------------

function MapBuilder.InitializeWorld()
	print("[MapBuilder] Building game world...")
	
	-- Create main map folder
	local mapFolder = game.Workspace:FindFirstChild("GameMap")
	if mapFolder then
		mapFolder:Destroy()
	end
	
	-- Build map
	local mapModel = MapBuilder.CreateMap()
	MapBuilder.CreateBarriers(mapModel)
	MapBuilder.AddDecorations(mapModel)
	MapBuilder.CreateBaseZoneMarkers(mapModel)
	MapBuilder.CreateKillZone(mapModel)
	MapBuilder.ConfigureLighting()
	
	mapModel.Parent = game.Workspace
	
	print("[MapBuilder] Game world complete!")
	print("[MapBuilder] Map size: " .. MAP_WIDTH .. " x " .. MAP_DEPTH .. " studs")
	print("[MapBuilder] Ready for 6 players")
end

------------------------------------------------------------
-- UTILITY FUNCTIONS
------------------------------------------------------------

function MapBuilder.GetMapCenter(): Vector3
	local centerX = (MAP_WIDTH / 2) - MAP_PADDING
	local centerZ = (MAP_DEPTH / 2) - MAP_PADDING
	return Vector3.new(centerX, 5, centerZ)
end

function MapBuilder.GetMapBounds(): {Min: Vector3, Max: Vector3}
	return {
		Min = Vector3.new(-MAP_PADDING - 20, -10, -MAP_PADDING - 20),
		Max = Vector3.new(MAP_WIDTH - MAP_PADDING + 20, 100, MAP_DEPTH - MAP_PADDING + 20)
	}
end

return MapBuilder
