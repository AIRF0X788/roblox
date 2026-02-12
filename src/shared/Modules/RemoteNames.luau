--[[
	RemoteNames.luau
	Centralized list of all remote event / function names.
	Both server and client reference this module so names stay in sync.
]]

local RemoteNames = {}

-- RemoteEvents (fire-and-forget)
RemoteNames.Events = {
	-- Server -> Client
	UpdateMoney            = "UpdateMoney",
	UpdateBrainrots        = "UpdateBrainrots",
	UpdateBaseLevel        = "UpdateBaseLevel",
	UpdateConveyorLevel    = "UpdateConveyorLevel",
	UpdateLuckLevel        = "UpdateLuckLevel",
	UpdateCollections      = "UpdateCollections",
	SpawnBoxOnBelt         = "SpawnBoxOnBelt",
	RemoveBoxFromBelt      = "RemoveBoxFromBelt",
	BoxPurchased           = "BoxPurchased",
	SpawnBrainrotVisual    = "SpawnBrainrotVisual",
	RemoveBrainrotVisual   = "RemoveBrainrotVisual",
	ShowNotification       = "ShowNotification",
	UpdateLeaderboard      = "UpdateLeaderboard",
	CollectionCompleted    = "CollectionCompleted",
	SyncAllData            = "SyncAllData",
	OpenLootbox            = "OpenLootbox",  -- Trigger lootbox animation

	-- Client -> Server
	RequestBuyBox          = "RequestBuyBox",
	RequestUpgradeBase     = "RequestUpgradeBase",
	RequestUpgradeConveyor = "RequestUpgradeConveyor",
	RequestUpgradeLuck     = "RequestUpgradeLuck",
	RequestSellBrainrot    = "RequestSellBrainrot",
	RequestCollectMoney    = "RequestCollectMoney",
}

-- RemoteFunctions (request-response)
RemoteNames.Functions = {
	GetPlayerData   = "GetPlayerData",
	GetLeaderboard  = "GetLeaderboard",
}

return RemoteNames
