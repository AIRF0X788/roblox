--[[
	DataManager.luau
	Manages player data: loading, saving, and in-memory access.
	Uses DataStoreService for persistence.
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)
local Utils = require(ReplicatedStorage.Shared.Modules.Utils)

local DataManager = {}

-- In-memory player data cache
local playerDataCache = {}

-- DataStore reference
local dataStore = nil
pcall(function()
	dataStore = DataStoreService:GetDataStore("BrainrotBoxes_v1")
end)

------------------------------------------------------------
-- LOAD / SAVE
------------------------------------------------------------

function DataManager.LoadPlayerData(player: Player)
	local defaultData = Utils.DeepCopy(GameConfig.DefaultPlayerData)
	local data = defaultData

	if dataStore then
		local success, result = pcall(function()
			return dataStore:GetAsync("Player_" .. player.UserId)
		end)

		if success and result then
			-- Merge saved data with defaults (handles new fields)
			for key, value in pairs(defaultData) do
				if result[key] == nil then
					result[key] = value
				end
			end
			data = result
		else
			if not success then
				warn("[DataManager] Failed to load data for " .. player.Name .. ": " .. tostring(result))
			end
		end
	end

	playerDataCache[player.UserId] = data
	print("[DataManager] Loaded data for " .. player.Name)
	return data
end

function DataManager.SavePlayerData(player: Player)
	local data = playerDataCache[player.UserId]
	if not data then return end

	if dataStore then
		local success, err = pcall(function()
			dataStore:SetAsync("Player_" .. player.UserId, data)
		end)

		if not success then
			warn("[DataManager] Failed to save data for " .. player.Name .. ": " .. tostring(err))
		else
			print("[DataManager] Saved data for " .. player.Name)
		end
	end
end

function DataManager.GetData(player: Player)
	return playerDataCache[player.UserId]
end

function DataManager.RemoveData(player: Player)
	DataManager.SavePlayerData(player)
	playerDataCache[player.UserId] = nil
end

------------------------------------------------------------
-- MONEY OPERATIONS
------------------------------------------------------------

function DataManager.GetMoney(player: Player): number
	local data = playerDataCache[player.UserId]
	return data and data.Money or 0
end

function DataManager.AddMoney(player: Player, amount: number)
	local data = playerDataCache[player.UserId]
	if data then
		data.Money = data.Money + amount
		data.TotalMoneyEarned = data.TotalMoneyEarned + math.max(0, amount)
	end
end

function DataManager.SpendMoney(player: Player, amount: number): boolean
	local data = playerDataCache[player.UserId]
	if data and data.Money >= amount then
		data.Money = data.Money - amount
		return true
	end
	return false
end

------------------------------------------------------------
-- BRAINROT OPERATIONS
------------------------------------------------------------

function DataManager.GetOwnedBrainrots(player: Player): { any }
	local data = playerDataCache[player.UserId]
	return data and data.OwnedBrainrots or {}
end

function DataManager.GetBrainrotCount(player: Player): number
	local data = playerDataCache[player.UserId]
	return data and #data.OwnedBrainrots or 0
end

function DataManager.AddBrainrot(player: Player, brainrotData: { Name: string, Rarity: string, MoneyPerCycle: number }): string?
	local data = playerDataCache[player.UserId]
	if not data then return nil end

	local maxBrainrots = GameConfig.GetMaxBrainrots(data.BaseLevel)
	if #data.OwnedBrainrots >= maxBrainrots then
		return nil  -- base is full
	end

	local id = Utils.GenerateId()
	table.insert(data.OwnedBrainrots, {
		Id = id,
		Name = brainrotData.Name,
		Rarity = brainrotData.Rarity,
		MoneyPerCycle = brainrotData.MoneyPerCycle,
	})

	-- Track for collections
	if not data.CollectedBrainrotNames then
		data.CollectedBrainrotNames = {}
	end
	data.CollectedBrainrotNames[brainrotData.Name] = true

	return id
end

function DataManager.RemoveBrainrot(player: Player, brainrotId: string): boolean
	local data = playerDataCache[player.UserId]
	if not data then return false end

	for i, brainrot in ipairs(data.OwnedBrainrots) do
		if brainrot.Id == brainrotId then
			table.remove(data.OwnedBrainrots, i)
			return true
		end
	end
	return false
end

-- Calculate total income per cycle from all owned brainrots
function DataManager.GetIncomePerCycle(player: Player): number
	local data = playerDataCache[player.UserId]
	if not data then return 0 end

	local total = 0
	for _, brainrot in ipairs(data.OwnedBrainrots) do
		total = total + (brainrot.MoneyPerCycle or 0)
	end
	return total
end

------------------------------------------------------------
-- UPGRADE OPERATIONS
------------------------------------------------------------

function DataManager.GetBaseLevel(player: Player): number
	local data = playerDataCache[player.UserId]
	return data and data.BaseLevel or 1
end

function DataManager.SetBaseLevel(player: Player, level: number)
	local data = playerDataCache[player.UserId]
	if data then
		data.BaseLevel = level
	end
end

function DataManager.GetConveyorLevel(player: Player): number
	local data = playerDataCache[player.UserId]
	return data and data.ConveyorLevel or 1
end

function DataManager.SetConveyorLevel(player: Player, level: number)
	local data = playerDataCache[player.UserId]
	if data then
		data.ConveyorLevel = level
	end
end

function DataManager.GetLuckLevel(player: Player): number
	local data = playerDataCache[player.UserId]
	return data and data.LuckLevel or 1
end

function DataManager.SetLuckLevel(player: Player, level: number)
	local data = playerDataCache[player.UserId]
	if data then
		data.LuckLevel = level
	end
end

------------------------------------------------------------
-- COLLECTION OPERATIONS
------------------------------------------------------------

function DataManager.GetCollectedBrainrotNames(player: Player): { [string]: boolean }
	local data = playerDataCache[player.UserId]
	return data and data.CollectedBrainrotNames or {}
end

function DataManager.GetCompletedCollections(player: Player): { string }
	local data = playerDataCache[player.UserId]
	return data and data.CompletedCollections or {}
end

function DataManager.MarkCollectionCompleted(player: Player, collectionName: string)
	local data = playerDataCache[player.UserId]
	if data then
		if not data.CompletedCollections then
			data.CompletedCollections = {}
		end
		table.insert(data.CompletedCollections, collectionName)
	end
end

function DataManager.IsCollectionCompleted(player: Player, collectionName: string): boolean
	local data = playerDataCache[player.UserId]
	if not data or not data.CompletedCollections then return false end

	for _, name in ipairs(data.CompletedCollections) do
		if name == collectionName then
			return true
		end
	end
	return false
end

------------------------------------------------------------
-- AUTO-SAVE
------------------------------------------------------------

function DataManager.StartAutoSave()
	task.spawn(function()
		while true do
			task.wait(60)  -- save every 60 seconds
			for _, player in ipairs(Players:GetPlayers()) do
				DataManager.SavePlayerData(player)
			end
		end
	end)
end

return DataManager
