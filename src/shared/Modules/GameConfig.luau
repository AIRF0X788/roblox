--[[
	GameConfig.luau
	Central configuration for the Brainrot Box Opening game.
	All rarities, boxes, brainrots, upgrades, and collections are defined here.
]]

local GameConfig = {}

------------------------------------------------------------
-- RARITY DEFINITIONS
------------------------------------------------------------
-- Each rarity has a color, a weight (for spawn probability on the conveyor),
-- and a glow intensity for visual feedback.

GameConfig.Rarities = {
	Common = {
		Order        = 1,
		Color        = Color3.fromRGB(180, 180, 180),  -- grey
		Weight       = 50,
		GlowIntensity = 0,
	},
	Uncommon = {
		Order        = 2,
		Color        = Color3.fromRGB(76, 175, 80),    -- green
		Weight       = 25,
		GlowIntensity = 0.3,
	},
	Rare = {
		Order        = 3,
		Color        = Color3.fromRGB(33, 150, 243),   -- blue
		Weight       = 13,
		GlowIntensity = 0.5,
	},
	Epic = {
		Order        = 4,
		Color        = Color3.fromRGB(156, 39, 176),   -- purple
		Weight       = 7,
		GlowIntensity = 0.7,
	},
	Legendary = {
		Order        = 5,
		Color        = Color3.fromRGB(255, 193, 7),    -- gold
		Weight       = 3.5,
		GlowIntensity = 0.9,
	},
	Mythic = {
		Order        = 6,
		Color        = Color3.fromRGB(244, 67, 54),    -- red
		Weight       = 1.2,
		GlowIntensity = 1,
	},
	Secret = {
		Order        = 7,
		Color        = Color3.fromRGB(0, 255, 255),    -- cyan / rainbow
		Weight       = 0.3,
		GlowIntensity = 1.2,
	},
}

------------------------------------------------------------
-- BRAINROT DEFINITIONS
-- Each brainrot belongs to a rarity and produces a certain
-- amount of money per collection cycle.
------------------------------------------------------------

GameConfig.Brainrots = {
	-- Common brainrots
	{ Name = "Skibidi Toilet",         Rarity = "Common",    MoneyPerCycle = 1,    ImageId = "rbxassetid://6023426926" },
	{ Name = "Baby Gronk",             Rarity = "Common",    MoneyPerCycle = 2,    ImageId = "rbxassetid://6023426926" },
	{ Name = "Grimace Shake",          Rarity = "Common",    MoneyPerCycle = 1,    ImageId = "rbxassetid://6023426926" },
	{ Name = "Ohio Rizz",              Rarity = "Common",    MoneyPerCycle = 2,    ImageId = "rbxassetid://6023426926" },

	-- Uncommon brainrots
	{ Name = "Sigma Boy",              Rarity = "Uncommon",  MoneyPerCycle = 5,    ImageId = "rbxassetid://6023426926" },
	{ Name = "Fanum Tax",              Rarity = "Uncommon",  MoneyPerCycle = 6,    ImageId = "rbxassetid://6023426926" },
	{ Name = "Mewing Streak",          Rarity = "Uncommon",  MoneyPerCycle = 5,    ImageId = "rbxassetid://6023426926" },

	-- Rare brainrots
	{ Name = "Gyatt Overlord",         Rarity = "Rare",      MoneyPerCycle = 15,   ImageId = "rbxassetid://6023426926" },
	{ Name = "Duke Dennis",            Rarity = "Rare",      MoneyPerCycle = 18,   ImageId = "rbxassetid://6023426926" },
	{ Name = "Livvy Dunne Rizz",       Rarity = "Rare",      MoneyPerCycle = 14,   ImageId = "rbxassetid://6023426926" },

	-- Epic brainrots
	{ Name = "Ice Spice Cube",         Rarity = "Epic",      MoneyPerCycle = 40,   ImageId = "rbxassetid://6023426926" },
	{ Name = "Kai Cenat Clone",        Rarity = "Epic",      MoneyPerCycle = 50,   ImageId = "rbxassetid://6023426926" },
	{ Name = "Sussy Imposter",         Rarity = "Epic",      MoneyPerCycle = 45,   ImageId = "rbxassetid://6023426926" },

	-- Legendary brainrots
	{ Name = "Golden Skibidi",         Rarity = "Legendary", MoneyPerCycle = 120,  ImageId = "rbxassetid://6023426926" },
	{ Name = "CameraMan Supreme",      Rarity = "Legendary", MoneyPerCycle = 150,  ImageId = "rbxassetid://6023426926" },

	-- Mythic brainrots
	{ Name = "Titan Speakerman",       Rarity = "Mythic",    MoneyPerCycle = 400,  ImageId = "rbxassetid://6023426926" },
	{ Name = "Astro Bot Sigma",        Rarity = "Mythic",    MoneyPerCycle = 500,  ImageId = "rbxassetid://6023426926" },

	-- Secret brainrots
	{ Name = "The One Piece Rizz God", Rarity = "Secret",    MoneyPerCycle = 1500, ImageId = "rbxassetid://6023426926" },
}

-- Build a lookup table by name for quick access
GameConfig.BrainrotsByName = {}
for _, brainrot in ipairs(GameConfig.Brainrots) do
	GameConfig.BrainrotsByName[brainrot.Name] = brainrot
end

-- Build a lookup table by rarity
GameConfig.BrainrotsByRarity = {}
for rarityName, _ in pairs(GameConfig.Rarities) do
	GameConfig.BrainrotsByRarity[rarityName] = {}
end
for _, brainrot in ipairs(GameConfig.Brainrots) do
	table.insert(GameConfig.BrainrotsByRarity[brainrot.Rarity], brainrot)
end

------------------------------------------------------------
-- BOX DEFINITIONS
-- Each box has a rarity, a price, and the number of brainrots
-- it will spawn when opened.
------------------------------------------------------------

GameConfig.Boxes = {
	{
		Name            = "Cardboard Box",
		Rarity          = "Common",
		Price           = 10,
		BrainrotCount   = 1,
		Size            = Vector3.new(3, 3, 3),
	},
	{
		Name            = "Green Crate",
		Rarity          = "Uncommon",
		Price           = 50,
		BrainrotCount   = 2,
		Size            = Vector3.new(3.5, 3.5, 3.5),
	},
	{
		Name            = "Blue Chest",
		Rarity          = "Rare",
		Price           = 200,
		BrainrotCount   = 3,
		Size            = Vector3.new(4, 4, 4),
	},
	{
		Name            = "Purple Vault",
		Rarity          = "Epic",
		Price           = 750,
		BrainrotCount   = 4,
		Size            = Vector3.new(4.5, 4.5, 4.5),
	},
	{
		Name            = "Golden Coffer",
		Rarity          = "Legendary",
		Price           = 3000,
		BrainrotCount   = 5,
		Size            = Vector3.new(5, 5, 5),
	},
	{
		Name            = "Infernal Case",
		Rarity          = "Mythic",
		Price           = 12000,
		BrainrotCount   = 6,
		Size            = Vector3.new(5.5, 5.5, 5.5),
	},
	{
		Name            = "??? Box",
		Rarity          = "Secret",
		Price           = 50000,
		BrainrotCount   = 8,
		Size            = Vector3.new(6, 6, 6),
	},
}

-- Build lookup by name
GameConfig.BoxesByName = {}
for _, box in ipairs(GameConfig.Boxes) do
	GameConfig.BoxesByName[box.Name] = box
end

------------------------------------------------------------
-- CONVEYOR SETTINGS
------------------------------------------------------------

GameConfig.Conveyor = {
	BeltLength     = 60,        -- studs long
	BeltWidth      = 6,         -- studs wide
	BeltHeight     = 3,         -- studs above ground
	BoxSpeed       = 8,         -- studs per second
	SpawnInterval  = 4,         -- seconds between each box spawn
	MaxBoxesOnBelt = 8,         -- max simultaneous boxes on a belt
}

------------------------------------------------------------
-- BASE UPGRADE LEVELS
-- Each level defines the max number of brainrots
-- the player can hold, and the upgrade cost.
------------------------------------------------------------

GameConfig.BaseUpgrades = {
	{ Level = 1,  MaxBrainrots = 5,    Cost = 0 },         -- starter
	{ Level = 2,  MaxBrainrots = 10,   Cost = 100 },
	{ Level = 3,  MaxBrainrots = 20,   Cost = 500 },
	{ Level = 4,  MaxBrainrots = 35,   Cost = 2000 },
	{ Level = 5,  MaxBrainrots = 50,   Cost = 8000 },
	{ Level = 6,  MaxBrainrots = 75,   Cost = 25000 },
	{ Level = 7,  MaxBrainrots = 100,  Cost = 75000 },
	{ Level = 8,  MaxBrainrots = 150,  Cost = 200000 },
	{ Level = 9,  MaxBrainrots = 200,  Cost = 500000 },
	{ Level = 10, MaxBrainrots = 300,  Cost = 1000000 },
}

------------------------------------------------------------
-- CONVEYOR UPGRADE LEVELS
-- Faster belt, more frequent boxes, etc.
------------------------------------------------------------

GameConfig.ConveyorUpgrades = {
	{ Level = 1,  SpeedMultiplier = 1.0, SpawnMultiplier = 1.0, Cost = 0 },
	{ Level = 2,  SpeedMultiplier = 1.0, SpawnMultiplier = 0.85, Cost = 300 },
	{ Level = 3,  SpeedMultiplier = 1.0, SpawnMultiplier = 0.7,  Cost = 1500 },
	{ Level = 4,  SpeedMultiplier = 1.1, SpawnMultiplier = 0.6,  Cost = 6000 },
	{ Level = 5,  SpeedMultiplier = 1.2, SpawnMultiplier = 0.5,  Cost = 20000 },
}

------------------------------------------------------------
-- LUCK UPGRADE LEVELS
-- Increases chances of higher-rarity boxes appearing
------------------------------------------------------------

GameConfig.LuckUpgrades = {
	{ Level = 1, RarityBoost = 0,    Cost = 0 },
	{ Level = 2, RarityBoost = 0.05, Cost = 500 },
	{ Level = 3, RarityBoost = 0.10, Cost = 2500 },
	{ Level = 4, RarityBoost = 0.18, Cost = 10000 },
	{ Level = 5, RarityBoost = 0.28, Cost = 50000 },
}

------------------------------------------------------------
-- COLLECTIONS
-- Groups of brainrots that give a bonus when completed.
------------------------------------------------------------

GameConfig.Collections = {
	{
		Name = "Street Brainrots",
		Description = "Collect all Common brainrots",
		RequiredBrainrots = { "Skibidi Toilet", "Baby Gronk", "Grimace Shake", "Ohio Rizz" },
		Reward = 500,
	},
	{
		Name = "Sigma Squad",
		Description = "Collect all Uncommon brainrots",
		RequiredBrainrots = { "Sigma Boy", "Fanum Tax", "Mewing Streak" },
		Reward = 2000,
	},
	{
		Name = "Rizz Masters",
		Description = "Collect all Rare brainrots",
		RequiredBrainrots = { "Gyatt Overlord", "Duke Dennis", "Livvy Dunne Rizz" },
		Reward = 8000,
	},
	{
		Name = "Elite Brainrots",
		Description = "Collect all Epic brainrots",
		RequiredBrainrots = { "Ice Spice Cube", "Kai Cenat Clone", "Sussy Imposter" },
		Reward = 30000,
	},
	{
		Name = "Golden Legends",
		Description = "Collect all Legendary brainrots",
		RequiredBrainrots = { "Golden Skibidi", "CameraMan Supreme" },
		Reward = 100000,
	},
	{
		Name = "Mythic Overlords",
		Description = "Collect all Mythic brainrots",
		RequiredBrainrots = { "Titan Speakerman", "Astro Bot Sigma" },
		Reward = 500000,
	},
	{
		Name = "The Final Secret",
		Description = "Find the rarest brainrot of all",
		RequiredBrainrots = { "The One Piece Rizz God" },
		Reward = 2000000,
	},
}

------------------------------------------------------------
-- MONEY COLLECTION CYCLE
------------------------------------------------------------

GameConfig.MoneyCollectionInterval = 5  -- seconds between each earnings tick

------------------------------------------------------------
-- PLAYER STARTING DATA
------------------------------------------------------------

GameConfig.DefaultPlayerData = {
	Money           = 50,      -- starting cash
	BaseLevel       = 1,
	ConveyorLevel   = 1,
	LuckLevel       = 1,
	OwnedBrainrots  = {},      -- { {Name=..., Id=...}, ... }
	CollectedBrainrotNames = {},  -- set of unique brainrot names ever owned (for collections)
	CompletedCollections = {},    -- list of collection names completed
	TotalMoneyEarned = 0,
}

------------------------------------------------------------
-- HELPER FUNCTIONS
------------------------------------------------------------

-- Weighted random selection for picking a box rarity
function GameConfig.PickRandomBoxRarity(luckBoost: number?): string
	local boost = luckBoost or 0
	local totalWeight = 0
	local weightTable = {}

	for rarityName, rarityData in pairs(GameConfig.Rarities) do
		local weight = rarityData.Weight
		-- Luck boost increases higher-rarity weights
		if rarityData.Order >= 3 then
			weight = weight * (1 + boost * rarityData.Order)
		end
		totalWeight = totalWeight + weight
		table.insert(weightTable, { Name = rarityName, Weight = weight })
	end

	local roll = math.random() * totalWeight
	local cumulative = 0
	for _, entry in ipairs(weightTable) do
		cumulative = cumulative + entry.Weight
		if roll <= cumulative then
			return entry.Name
		end
	end

	return "Common"  -- fallback
end

-- Pick a random box config for a given rarity
function GameConfig.GetBoxForRarity(rarity: string)
	for _, box in ipairs(GameConfig.Boxes) do
		if box.Rarity == rarity then
			return box
		end
	end
	return GameConfig.Boxes[1]  -- fallback
end

-- Pick random brainrots from the box's rarity (and potentially lower rarities)
function GameConfig.RollBrainrots(boxRarity: string, count: number): { any }
	local results = {}
	local rarityOrder = GameConfig.Rarities[boxRarity].Order

	for _ = 1, count do
		-- 70% chance same rarity, 30% chance lower rarity
		local targetRarity = boxRarity
		if math.random() < 0.30 and rarityOrder > 1 then
			-- Pick a random lower rarity
			local lowerRarities = {}
			for rName, rData in pairs(GameConfig.Rarities) do
				if rData.Order < rarityOrder then
					table.insert(lowerRarities, rName)
				end
			end
			if #lowerRarities > 0 then
				targetRarity = lowerRarities[math.random(1, #lowerRarities)]
			end
		end

		local pool = GameConfig.BrainrotsByRarity[targetRarity]
		if pool and #pool > 0 then
			local picked = pool[math.random(1, #pool)]
			table.insert(results, {
				Name = picked.Name,
				Rarity = picked.Rarity,
				MoneyPerCycle = picked.MoneyPerCycle,
			})
		end
	end

	return results
end

-- Get max brainrots for a base level
function GameConfig.GetMaxBrainrots(baseLevel: number): number
	local upgrade = GameConfig.BaseUpgrades[baseLevel]
	if upgrade then
		return upgrade.MaxBrainrots
	end
	return GameConfig.BaseUpgrades[#GameConfig.BaseUpgrades].MaxBrainrots
end

-- Get upgrade cost
function GameConfig.GetBaseUpgradeCost(currentLevel: number): number?
	local nextUpgrade = GameConfig.BaseUpgrades[currentLevel + 1]
	if nextUpgrade then
		return nextUpgrade.Cost
	end
	return nil  -- already max level
end

function GameConfig.GetConveyorUpgradeCost(currentLevel: number): number?
	local nextUpgrade = GameConfig.ConveyorUpgrades[currentLevel + 1]
	if nextUpgrade then
		return nextUpgrade.Cost
	end
	return nil
end

function GameConfig.GetLuckUpgradeCost(currentLevel: number): number?
	local nextUpgrade = GameConfig.LuckUpgrades[currentLevel + 1]
	if nextUpgrade then
		return nextUpgrade.Cost
	end
	return nil
end

return GameConfig
