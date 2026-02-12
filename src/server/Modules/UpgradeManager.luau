--[[
	UpgradeManager.luau
	Handles all upgrade logic: base, conveyor, and luck.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)
local RemoteNames = require(ReplicatedStorage.Shared.Modules.RemoteNames)
local Utils = require(ReplicatedStorage.Shared.Modules.Utils)
local RemoteSetup = require(script.Parent.RemoteSetup)
local DataManager = require(script.Parent.DataManager)
local BaseBuilder = require(script.Parent.BaseBuilder)

local UpgradeManager = {}

------------------------------------------------------------
-- BASE UPGRADE
------------------------------------------------------------

function UpgradeManager.TryUpgradeBase(player: Player): boolean
	local currentLevel = DataManager.GetBaseLevel(player)
	local cost = GameConfig.GetBaseUpgradeCost(currentLevel)

	if not cost then
		-- Max level
		local notifEvent = RemoteSetup.GetEvent(RemoteNames.Events.ShowNotification)
		if notifEvent then
			notifEvent:FireClient(player, {
				Title = "Max Level!",
				Text = "Your base is already at maximum level.",
				Color = Color3.fromRGB(255, 200, 50),
			})
		end
		return false
	end

	if not DataManager.SpendMoney(player, cost) then
		local notifEvent = RemoteSetup.GetEvent(RemoteNames.Events.ShowNotification)
		if notifEvent then
			notifEvent:FireClient(player, {
				Title = "Not enough money!",
				Text = "You need " .. Utils.FormatMoney(cost) .. " to upgrade.",
				Color = Color3.fromRGB(255, 80, 80),
			})
		end
		return false
	end

	local newLevel = currentLevel + 1
	DataManager.SetBaseLevel(player, newLevel)
	BaseBuilder.UpdateLevelSign(player, newLevel)

	-- Notify client
	local moneyEvent = RemoteSetup.GetEvent(RemoteNames.Events.UpdateMoney)
	if moneyEvent then
		moneyEvent:FireClient(player, DataManager.GetMoney(player))
	end

	local baseLevelEvent = RemoteSetup.GetEvent(RemoteNames.Events.UpdateBaseLevel)
	if baseLevelEvent then
		baseLevelEvent:FireClient(player, newLevel)
	end

	local maxBrainrots = GameConfig.GetMaxBrainrots(newLevel)
	local notifEvent = RemoteSetup.GetEvent(RemoteNames.Events.ShowNotification)
	if notifEvent then
		notifEvent:FireClient(player, {
			Title = "Base Upgraded!",
			Text = "Level " .. newLevel .. " - Max Brainrots: " .. maxBrainrots,
			Color = Color3.fromRGB(100, 200, 255),
		})
	end

	return true
end

------------------------------------------------------------
-- CONVEYOR UPGRADE
------------------------------------------------------------

function UpgradeManager.TryUpgradeConveyor(player: Player): boolean
	local currentLevel = DataManager.GetConveyorLevel(player)
	local cost = GameConfig.GetConveyorUpgradeCost(currentLevel)

	if not cost then
		local notifEvent = RemoteSetup.GetEvent(RemoteNames.Events.ShowNotification)
		if notifEvent then
			notifEvent:FireClient(player, {
				Title = "Max Level!",
				Text = "Your conveyor is already at maximum level.",
				Color = Color3.fromRGB(255, 200, 50),
			})
		end
		return false
	end

	if not DataManager.SpendMoney(player, cost) then
		local notifEvent = RemoteSetup.GetEvent(RemoteNames.Events.ShowNotification)
		if notifEvent then
			notifEvent:FireClient(player, {
				Title = "Not enough money!",
				Text = "You need " .. Utils.FormatMoney(cost) .. " to upgrade.",
				Color = Color3.fromRGB(255, 80, 80),
			})
		end
		return false
	end

	local newLevel = currentLevel + 1
	DataManager.SetConveyorLevel(player, newLevel)

	local moneyEvent = RemoteSetup.GetEvent(RemoteNames.Events.UpdateMoney)
	if moneyEvent then
		moneyEvent:FireClient(player, DataManager.GetMoney(player))
	end

	local convLevelEvent = RemoteSetup.GetEvent(RemoteNames.Events.UpdateConveyorLevel)
	if convLevelEvent then
		convLevelEvent:FireClient(player, newLevel)
	end

	local notifEvent = RemoteSetup.GetEvent(RemoteNames.Events.ShowNotification)
	if notifEvent then
		notifEvent:FireClient(player, {
			Title = "Conveyor Upgraded!",
			Text = "Level " .. newLevel .. " - Boxes spawn faster!",
			Color = Color3.fromRGB(100, 200, 255),
		})
	end

	return true
end

------------------------------------------------------------
-- LUCK UPGRADE
------------------------------------------------------------

function UpgradeManager.TryUpgradeLuck(player: Player): boolean
	local currentLevel = DataManager.GetLuckLevel(player)
	local cost = GameConfig.GetLuckUpgradeCost(currentLevel)

	if not cost then
		local notifEvent = RemoteSetup.GetEvent(RemoteNames.Events.ShowNotification)
		if notifEvent then
			notifEvent:FireClient(player, {
				Title = "Max Level!",
				Text = "Your luck is already at maximum level.",
				Color = Color3.fromRGB(255, 200, 50),
			})
		end
		return false
	end

	if not DataManager.SpendMoney(player, cost) then
		local notifEvent = RemoteSetup.GetEvent(RemoteNames.Events.ShowNotification)
		if notifEvent then
			notifEvent:FireClient(player, {
				Title = "Not enough money!",
				Text = "You need " .. Utils.FormatMoney(cost) .. " to upgrade.",
				Color = Color3.fromRGB(255, 80, 80),
			})
		end
		return false
	end

	local newLevel = currentLevel + 1
	DataManager.SetLuckLevel(player, newLevel)

	local moneyEvent = RemoteSetup.GetEvent(RemoteNames.Events.UpdateMoney)
	if moneyEvent then
		moneyEvent:FireClient(player, DataManager.GetMoney(player))
	end

	local luckLevelEvent = RemoteSetup.GetEvent(RemoteNames.Events.UpdateLuckLevel)
	if luckLevelEvent then
		luckLevelEvent:FireClient(player, newLevel)
	end

	local notifEvent = RemoteSetup.GetEvent(RemoteNames.Events.ShowNotification)
	if notifEvent then
		notifEvent:FireClient(player, {
			Title = "Luck Upgraded!",
			Text = "Level " .. newLevel .. " - Better box rarities!",
			Color = Color3.fromRGB(200, 100, 255),
		})
	end

	return true
end

return UpgradeManager
