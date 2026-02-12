--[[
	LeaderboardManager.luau
	Manages the in-game leaderboard (leaderstats) and a periodic
	server-wide money ranking.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteNames = require(ReplicatedStorage.Shared.Modules.RemoteNames)
local RemoteSetup = require(script.Parent.RemoteSetup)
local DataManager = require(script.Parent.DataManager)

local LeaderboardManager = {}

-- Cache the leaderboard
local leaderboardCache = {}

------------------------------------------------------------
-- LEADERSTATS (the native Roblox leaderboard)
------------------------------------------------------------

function LeaderboardManager.CreateLeaderstats(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = 0
	money.Parent = leaderstats

	local brainrots = Instance.new("IntValue")
	brainrots.Name = "Brainrots"
	brainrots.Value = 0
	brainrots.Parent = leaderstats
end

function LeaderboardManager.UpdateLeaderstats(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local moneyVal = leaderstats:FindFirstChild("Money")
	if moneyVal then
		moneyVal.Value = math.floor(DataManager.GetMoney(player))
	end

	local brainrotsVal = leaderstats:FindFirstChild("Brainrots")
	if brainrotsVal then
		brainrotsVal.Value = DataManager.GetBrainrotCount(player)
	end
end

------------------------------------------------------------
-- PERIODIC LEADERBOARD UPDATE
------------------------------------------------------------

function LeaderboardManager.StartPeriodicUpdate()
	task.spawn(function()
		while true do
			-- Update leaderstats for all players
			for _, player in ipairs(Players:GetPlayers()) do
				LeaderboardManager.UpdateLeaderstats(player)
			end

			-- Build ranking
			local ranking = {}
			for _, player in ipairs(Players:GetPlayers()) do
				local data = DataManager.GetData(player)
				if data then
					table.insert(ranking, {
						Name = player.Name,
						DisplayName = player.DisplayName,
						Money = data.Money,
						TotalEarned = data.TotalMoneyEarned,
						BrainrotCount = #data.OwnedBrainrots,
					})
				end
			end

			-- Sort by total money earned
			table.sort(ranking, function(a, b)
				return a.TotalEarned > b.TotalEarned
			end)

			leaderboardCache = ranking

			-- Broadcast to all clients
			local lbEvent = RemoteSetup.GetEvent(RemoteNames.Events.UpdateLeaderboard)
			if lbEvent then
				for _, player in ipairs(Players:GetPlayers()) do
					lbEvent:FireClient(player, ranking)
				end
			end

			task.wait(5)  -- update every 5 seconds
		end
	end)
end

function LeaderboardManager.GetLeaderboard(): { any }
	return leaderboardCache
end

return LeaderboardManager
