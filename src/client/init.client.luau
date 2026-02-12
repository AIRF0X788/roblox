--[[
	Client Init - BrainrotBoxes
	Main client entry point.
	Sets up all UI, connects remote events to update local state.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for shared modules
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Modules = Shared:WaitForChild("Modules")

local GameConfig = require(Modules.GameConfig)
local RemoteNames = require(Modules.RemoteNames)
local Utils = require(Modules.Utils)

-- Client controllers
local RemoteHelper = require(script.Controllers.RemoteHelper)
local PlayerState = require(script.Controllers.PlayerState)

-- UI modules
local UIBuilder = require(script.UI.UIBuilder)
local HudUI = require(script.UI.HudUI)
local UpgradeUI = require(script.UI.UpgradeUI)
local CollectionUI = require(script.UI.CollectionUI)
local BrainrotListUI = require(script.UI.BrainrotListUI)
local NotificationUI = require(script.UI.NotificationUI)
local LeaderboardUI = require(script.UI.LeaderboardUI)

local player = Players.LocalPlayer

------------------------------------------------------------
-- INITIALIZATION
------------------------------------------------------------

print("=== BrainrotBoxes Client Starting ===")

-- Create all UI
HudUI.Create()
UpgradeUI.Create()
CollectionUI.Create()
BrainrotListUI.Create()
NotificationUI.Create()
LeaderboardUI.Create()

------------------------------------------------------------
-- CONNECT PLAYER STATE CALLBACKS TO UI
------------------------------------------------------------

PlayerState.OnMoneyChanged = function(amount)
	HudUI.UpdateMoney(amount)
end

PlayerState.OnBrainrotsChanged = function(brainrots)
	HudUI.UpdateBrainrots(brainrots, PlayerState.MaxBrainrots)
	BrainrotListUI.UpdateList(brainrots)
end

PlayerState.OnBaseLevelChanged = function(level)
	UpgradeUI.UpdateBaseLevel(level)
	-- Also update brainrot count display (max changed)
	HudUI.UpdateBrainrots(PlayerState.Brainrots, PlayerState.MaxBrainrots)
end

PlayerState.OnConveyorLevelChanged = function(level)
	UpgradeUI.UpdateConveyorLevel(level)
end

PlayerState.OnLuckLevelChanged = function(level)
	UpgradeUI.UpdateLuckLevel(level)
end

PlayerState.OnCollectionsChanged = function(status)
	CollectionUI.UpdateCollections(status)
end

PlayerState.OnLeaderboardChanged = function(rankings)
	LeaderboardUI.UpdateLeaderboard(rankings)
end

PlayerState.OnNotification = function(data)
	NotificationUI.Show(data)
end

PlayerState.OnBoxPurchased = function(data)
	NotificationUI.ShowBoxPurchase(data)
end

PlayerState.OnCollectionCompleted = function(data)
	NotificationUI.ShowCollectionComplete(data)
end

------------------------------------------------------------
-- CONNECT REMOTE EVENTS
------------------------------------------------------------

-- Sync all data (on join)
local syncEvent = RemoteHelper.GetEvent(RemoteNames.Events.SyncAllData)
if syncEvent then
	syncEvent.OnClientEvent:Connect(function(data)
		PlayerState.SyncAll(data)
		print("[Client] Data synced from server.")
	end)
end

-- Money updates
local moneyEvent = RemoteHelper.GetEvent(RemoteNames.Events.UpdateMoney)
if moneyEvent then
	moneyEvent.OnClientEvent:Connect(function(amount)
		PlayerState.SetMoney(amount)
	end)
end

-- Brainrot updates
local brainrotEvent = RemoteHelper.GetEvent(RemoteNames.Events.UpdateBrainrots)
if brainrotEvent then
	brainrotEvent.OnClientEvent:Connect(function(brainrots)
		PlayerState.SetBrainrots(brainrots)
	end)
end

-- Base level
local baseLevelEvent = RemoteHelper.GetEvent(RemoteNames.Events.UpdateBaseLevel)
if baseLevelEvent then
	baseLevelEvent.OnClientEvent:Connect(function(level)
		PlayerState.SetBaseLevel(level)
	end)
end

-- Conveyor level
local convLevelEvent = RemoteHelper.GetEvent(RemoteNames.Events.UpdateConveyorLevel)
if convLevelEvent then
	convLevelEvent.OnClientEvent:Connect(function(level)
		PlayerState.SetConveyorLevel(level)
	end)
end

-- Luck level
local luckLevelEvent = RemoteHelper.GetEvent(RemoteNames.Events.UpdateLuckLevel)
if luckLevelEvent then
	luckLevelEvent.OnClientEvent:Connect(function(level)
		PlayerState.SetLuckLevel(level)
	end)
end

-- Leaderboard
local lbEvent = RemoteHelper.GetEvent(RemoteNames.Events.UpdateLeaderboard)
if lbEvent then
	lbEvent.OnClientEvent:Connect(function(rankings)
		PlayerState.SetLeaderboard(rankings)
	end)
end

-- Notifications
local notifEvent = RemoteHelper.GetEvent(RemoteNames.Events.ShowNotification)
if notifEvent then
	notifEvent.OnClientEvent:Connect(function(data)
		NotificationUI.Show(data)
	end)
end

-- Box purchased
local purchaseEvent = RemoteHelper.GetEvent(RemoteNames.Events.BoxPurchased)
if purchaseEvent then
	purchaseEvent.OnClientEvent:Connect(function(data)
		NotificationUI.ShowBoxPurchase(data)
	end)
end

-- Collection completed
local collCompletedEvent = RemoteHelper.GetEvent(RemoteNames.Events.CollectionCompleted)
if collCompletedEvent then
	collCompletedEvent.OnClientEvent:Connect(function(data)
		NotificationUI.ShowCollectionComplete(data)
	end)
end

-- Collection status update
local updateCollectionsEvent = RemoteHelper.GetEvent(RemoteNames.Events.UpdateCollections)
if updateCollectionsEvent then
	updateCollectionsEvent.OnClientEvent:Connect(function(completedCollections)
		-- Re-fetch full collection status
		local playerData = RemoteHelper.InvokeServer(RemoteNames.Functions.GetPlayerData)
		if playerData and playerData.CollectionStatus then
			PlayerState.CollectionStatus = playerData.CollectionStatus
			CollectionUI.UpdateCollections(playerData.CollectionStatus)
		end
	end)
end

------------------------------------------------------------
-- INITIAL DATA FETCH (fallback if SyncAllData was missed)
------------------------------------------------------------

task.delay(3, function()
	if PlayerState.Money == 0 then
		print("[Client] Fallback: requesting player data...")
		local data = RemoteHelper.InvokeServer(RemoteNames.Functions.GetPlayerData)
		if data then
			PlayerState.SyncAll(data)
		end
	end
end)

print("=== BrainrotBoxes Client Ready ===")
