--[[
	CollectionManager.luau
	Checks and awards collection completions.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)
local RemoteNames = require(ReplicatedStorage.Shared.Modules.RemoteNames)
local Utils = require(ReplicatedStorage.Shared.Modules.Utils)
local RemoteSetup = require(script.Parent.RemoteSetup)
local DataManager = require(script.Parent.DataManager)

local CollectionManager = {}

------------------------------------------------------------
-- CHECK COLLECTIONS
-- Call this whenever a player gains a new brainrot.
------------------------------------------------------------

function CollectionManager.CheckCollections(player: Player)
	local collectedNames = DataManager.GetCollectedBrainrotNames(player)

	for _, collection in ipairs(GameConfig.Collections) do
		-- Skip if already completed
		if DataManager.IsCollectionCompleted(player, collection.Name) then
			continue
		end

		-- Check if all required brainrots have been collected
		local allCollected = true
		for _, requiredName in ipairs(collection.RequiredBrainrots) do
			if not collectedNames[requiredName] then
				allCollected = false
				break
			end
		end

		if allCollected then
			-- Complete the collection!
			DataManager.MarkCollectionCompleted(player, collection.Name)
			DataManager.AddMoney(player, collection.Reward)

			-- Update client
			local moneyEvent = RemoteSetup.GetEvent(RemoteNames.Events.UpdateMoney)
			if moneyEvent then
				moneyEvent:FireClient(player, DataManager.GetMoney(player))
			end

			local collectionEvent = RemoteSetup.GetEvent(RemoteNames.Events.CollectionCompleted)
			if collectionEvent then
				collectionEvent:FireClient(player, {
					CollectionName = collection.Name,
					Reward = collection.Reward,
				})
			end

			local notifEvent = RemoteSetup.GetEvent(RemoteNames.Events.ShowNotification)
			if notifEvent then
				notifEvent:FireClient(player, {
					Title = "Collection Complete!",
					Text = collection.Name .. " - Reward: " .. Utils.FormatMoney(collection.Reward),
					Color = Color3.fromRGB(255, 215, 0),
				})
			end

			local updateCollectionsEvent = RemoteSetup.GetEvent(RemoteNames.Events.UpdateCollections)
			if updateCollectionsEvent then
				updateCollectionsEvent:FireClient(player, DataManager.GetCompletedCollections(player))
			end
		end
	end
end

------------------------------------------------------------
-- GET COLLECTION STATUS (for UI display)
------------------------------------------------------------

function CollectionManager.GetCollectionStatus(player: Player): { any }
	local collectedNames = DataManager.GetCollectedBrainrotNames(player)
	local status = {}

	for _, collection in ipairs(GameConfig.Collections) do
		local completed = DataManager.IsCollectionCompleted(player, collection.Name)
		local ownedCount = 0
		local brainrotStatus = {}

		for _, requiredName in ipairs(collection.RequiredBrainrots) do
			local owned = collectedNames[requiredName] == true
			if owned then
				ownedCount = ownedCount + 1
			end
			table.insert(brainrotStatus, {
				Name = requiredName,
				Owned = owned,
			})
		end

		table.insert(status, {
			Name = collection.Name,
			Description = collection.Description,
			Completed = completed,
			Reward = collection.Reward,
			Progress = ownedCount .. "/" .. #collection.RequiredBrainrots,
			Brainrots = brainrotStatus,
		})
	end

	return status
end

return CollectionManager
