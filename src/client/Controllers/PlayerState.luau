--[[
	PlayerState.luau (Client)
	Stores the local player's synced state.
	Provides signals when state changes for UI updates.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteNames = require(ReplicatedStorage:WaitForChild("Shared").Modules.RemoteNames)

local PlayerState = {}

-- Current state
PlayerState.Money = 0
PlayerState.BaseLevel = 1
PlayerState.ConveyorLevel = 1
PlayerState.LuckLevel = 1
PlayerState.Brainrots = {}
PlayerState.MaxBrainrots = 5
PlayerState.CompletedCollections = {}
PlayerState.CollectionStatus = {}
PlayerState.Leaderboard = {}

-- Callbacks for UI updates
PlayerState.OnMoneyChanged = nil           -- function(newMoney)
PlayerState.OnBrainrotsChanged = nil       -- function(brainrots)
PlayerState.OnBaseLevelChanged = nil       -- function(newLevel)
PlayerState.OnConveyorLevelChanged = nil   -- function(newLevel)
PlayerState.OnLuckLevelChanged = nil       -- function(newLevel)
PlayerState.OnCollectionsChanged = nil     -- function(status)
PlayerState.OnLeaderboardChanged = nil     -- function(rankings)
PlayerState.OnNotification = nil           -- function(data)
PlayerState.OnBoxPurchased = nil           -- function(data)
PlayerState.OnCollectionCompleted = nil    -- function(data)

function PlayerState.SetMoney(amount: number)
	PlayerState.Money = amount
	if PlayerState.OnMoneyChanged then
		PlayerState.OnMoneyChanged(amount)
	end
end

function PlayerState.SetBrainrots(brainrots: { any })
	PlayerState.Brainrots = brainrots
	if PlayerState.OnBrainrotsChanged then
		PlayerState.OnBrainrotsChanged(brainrots)
	end
end

function PlayerState.SetBaseLevel(level: number)
	PlayerState.BaseLevel = level
	local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)
	PlayerState.MaxBrainrots = GameConfig.GetMaxBrainrots(level)
	if PlayerState.OnBaseLevelChanged then
		PlayerState.OnBaseLevelChanged(level)
	end
end

function PlayerState.SetConveyorLevel(level: number)
	PlayerState.ConveyorLevel = level
	if PlayerState.OnConveyorLevelChanged then
		PlayerState.OnConveyorLevelChanged(level)
	end
end

function PlayerState.SetLuckLevel(level: number)
	PlayerState.LuckLevel = level
	if PlayerState.OnLuckLevelChanged then
		PlayerState.OnLuckLevelChanged(level)
	end
end

function PlayerState.SetLeaderboard(rankings: { any })
	PlayerState.Leaderboard = rankings
	if PlayerState.OnLeaderboardChanged then
		PlayerState.OnLeaderboardChanged(rankings)
	end
end

function PlayerState.SyncAll(data)
	if data.Money then PlayerState.Money = data.Money end
	if data.BaseLevel then PlayerState.BaseLevel = data.BaseLevel end
	if data.ConveyorLevel then PlayerState.ConveyorLevel = data.ConveyorLevel end
	if data.LuckLevel then PlayerState.LuckLevel = data.LuckLevel end
	if data.Brainrots then PlayerState.Brainrots = data.Brainrots end
	if data.MaxBrainrots then PlayerState.MaxBrainrots = data.MaxBrainrots end
	if data.CompletedCollections then PlayerState.CompletedCollections = data.CompletedCollections end
	if data.CollectionStatus then PlayerState.CollectionStatus = data.CollectionStatus end

	-- Fire all callbacks
	if PlayerState.OnMoneyChanged then PlayerState.OnMoneyChanged(PlayerState.Money) end
	if PlayerState.OnBrainrotsChanged then PlayerState.OnBrainrotsChanged(PlayerState.Brainrots) end
	if PlayerState.OnBaseLevelChanged then PlayerState.OnBaseLevelChanged(PlayerState.BaseLevel) end
	if PlayerState.OnConveyorLevelChanged then PlayerState.OnConveyorLevelChanged(PlayerState.ConveyorLevel) end
	if PlayerState.OnLuckLevelChanged then PlayerState.OnLuckLevelChanged(PlayerState.LuckLevel) end
	if PlayerState.OnCollectionsChanged then PlayerState.OnCollectionsChanged(PlayerState.CollectionStatus) end
end

return PlayerState
