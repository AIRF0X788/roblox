--[[
	Server Init - BrainrotBoxes
	Main server entry point.
	Sets up all systems and handles player join/leave.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for shared modules to replicate
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Modules = Shared:WaitForChild("Modules")

local GameConfig = require(Modules.GameConfig)
local RemoteNames = require(Modules.RemoteNames)
local Utils = require(Modules.Utils)

-- Server modules
local ServerModules = script.Modules
local RemoteSetup = require(ServerModules.RemoteSetup)
local DataManager = require(ServerModules.DataManager)
local BaseBuilder = require(ServerModules.BaseBuilder)
local ConveyorManager = require(ServerModules.ConveyorManager)
local BrainrotManager = require(ServerModules.BrainrotManager)
local UpgradeManager = require(ServerModules.UpgradeManager)
local CollectionManager = require(ServerModules.CollectionManager)
local LeaderboardManager = require(ServerModules.LeaderboardManager)
local MapBuilder = require(ServerModules.MapBuilder)

------------------------------------------------------------
-- INITIALIZATION
------------------------------------------------------------

print("=== BrainrotBoxes Server Starting ===")

-- Initialize game world/map first
MapBuilder.InitializeWorld()

-- Create Bases folder in Workspace if it doesn't exist
if not game.Workspace:FindFirstChild("Bases") then
	local basesFolder = Instance.new("Folder")
	basesFolder.Name = "Bases"
	basesFolder.Parent = game.Workspace
	print("[Server] Created Bases folder in Workspace")
end

-- Create all remote events/functions
RemoteSetup.Init()

-- Start auto-save
DataManager.StartAutoSave()

-- Start leaderboard updates
LeaderboardManager.StartPeriodicUpdate()

------------------------------------------------------------
-- PLAYER JOIN
------------------------------------------------------------

local function onPlayerJoin(player: Player)
	print("[Server] Player joining: " .. player.Name)

	-- Load data
	local data = DataManager.LoadPlayerData(player)

	-- Create leaderstats
	LeaderboardManager.CreateLeaderstats(player)
	LeaderboardManager.UpdateLeaderstats(player)

	-- Build physical base
	local base = BaseBuilder.CreateBase(player)
	BaseBuilder.UpdateLevelSign(player, data.BaseLevel)

	-- Small delay to let client set up
	task.wait(1)

	-- Spawn existing brainrots visually
	BrainrotManager.SpawnAllBrainrots(player)

	-- Start conveyor belt
	ConveyorManager.StartConveyor(player)

	-- Start money collection cycle
	BrainrotManager.StartMoneyCollection(player)

	-- Sync all data to client
	local syncEvent = RemoteSetup.GetEvent(RemoteNames.Events.SyncAllData)
	if syncEvent then
		syncEvent:FireClient(player, {
			Money = data.Money,
			BaseLevel = data.BaseLevel,
			ConveyorLevel = data.ConveyorLevel,
			LuckLevel = data.LuckLevel,
			Brainrots = data.OwnedBrainrots,
			CompletedCollections = data.CompletedCollections or {},
			CollectionStatus = CollectionManager.GetCollectionStatus(player),
			MaxBrainrots = GameConfig.GetMaxBrainrots(data.BaseLevel),
		})
	end

	-- Teleport player to their spawn
	local spawnPoint = base:FindFirstChild("SpawnPoint")
	if spawnPoint and player.Character then
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = spawnPoint.CFrame + Vector3.new(0, 3, 0)
		end
	end

	-- Also handle character respawning
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		local hrp = character:FindFirstChild("HumanoidRootPart")
		local currentBase = BaseBuilder.GetBase(player)
		if hrp and currentBase then
			local spawn = currentBase:FindFirstChild("SpawnPoint")
			if spawn then
				hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
			end
		end
	end)

	print("[Server] Player setup complete: " .. player.Name)
end

------------------------------------------------------------
-- PLAYER LEAVE
------------------------------------------------------------

local function onPlayerLeave(player: Player)
	print("[Server] Player leaving: " .. player.Name)

	-- Stop systems
	ConveyorManager.StopConveyor(player)
	BrainrotManager.StopMoneyCollection(player)
	BrainrotManager.ClearAllBrainrots(player)

	-- Save and clean data
	DataManager.RemoveData(player)

	-- Destroy base
	BaseBuilder.DestroyBase(player)
end

------------------------------------------------------------
-- REMOTE EVENT HANDLERS
------------------------------------------------------------

-- Wait for remotes to be created
task.wait(0.5)

-- Buy box request (from ClickDetector, but also from client UI)
local buyBoxEvent = RemoteSetup.GetEvent(RemoteNames.Events.RequestBuyBox)
if buyBoxEvent then
	buyBoxEvent.OnServerEvent:Connect(function(player, data)
		if data and data.BoxId then
			ConveyorManager.TryBuyBox(player, data.BoxId)
			-- Check collections after buying
			CollectionManager.CheckCollections(player)
		end
	end)
end

-- Upgrade base
local upgradeBaseEvent = RemoteSetup.GetEvent(RemoteNames.Events.RequestUpgradeBase)
if upgradeBaseEvent then
	upgradeBaseEvent.OnServerEvent:Connect(function(player)
		UpgradeManager.TryUpgradeBase(player)
	end)
end

-- Upgrade conveyor
local upgradeConvEvent = RemoteSetup.GetEvent(RemoteNames.Events.RequestUpgradeConveyor)
if upgradeConvEvent then
	upgradeConvEvent.OnServerEvent:Connect(function(player)
		UpgradeManager.TryUpgradeConveyor(player)
	end)
end

-- Upgrade luck
local upgradeLuckEvent = RemoteSetup.GetEvent(RemoteNames.Events.RequestUpgradeLuck)
if upgradeLuckEvent then
	upgradeLuckEvent.OnServerEvent:Connect(function(player)
		UpgradeManager.TryUpgradeLuck(player)
	end)
end

-- Sell brainrot
local sellEvent = RemoteSetup.GetEvent(RemoteNames.Events.RequestSellBrainrot)
if sellEvent then
	sellEvent.OnServerEvent:Connect(function(player, data)
		if data and data.BrainrotId then
			BrainrotManager.SellBrainrot(player, data.BrainrotId)
		end
	end)
end

-- GetPlayerData function
local getDataFunc = RemoteSetup.GetFunction(RemoteNames.Functions.GetPlayerData)
if getDataFunc then
	getDataFunc.OnServerInvoke = function(player)
		local data = DataManager.GetData(player)
		if data then
			return {
				Money = data.Money,
				BaseLevel = data.BaseLevel,
				ConveyorLevel = data.ConveyorLevel,
				LuckLevel = data.LuckLevel,
				Brainrots = data.OwnedBrainrots,
				CompletedCollections = data.CompletedCollections or {},
				CollectionStatus = CollectionManager.GetCollectionStatus(player),
				MaxBrainrots = GameConfig.GetMaxBrainrots(data.BaseLevel),
			}
		end
		return nil
	end
end

-- GetLeaderboard function
local getLeaderboardFunc = RemoteSetup.GetFunction(RemoteNames.Functions.GetLeaderboard)
if getLeaderboardFunc then
	getLeaderboardFunc.OnServerInvoke = function(_player)
		return LeaderboardManager.GetLeaderboard()
	end
end

------------------------------------------------------------
-- CONNECT EVENTS
------------------------------------------------------------

Players.PlayerAdded:Connect(onPlayerJoin)
Players.PlayerRemoving:Connect(onPlayerLeave)

-- Handle players who joined before this script ran
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerJoin, player)
end

print("=== BrainrotBoxes Server Ready ===")
