--[[
	TestConveyor.luau
	Debug script to manually test conveyor spawning.
	Place this in ServerScriptService to test.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Wait for server to initialize
task.wait(3)

local ConveyorManager = require(ServerScriptService.Server.Modules.ConveyorManager)
local BaseBuilder = require(ServerScriptService.Server.Modules.BaseBuilder)

print("=== CONVEYOR DEBUG TEST ===")

-- Test for first player
Players.PlayerAdded:Connect(function(player)
	task.wait(5)  -- Wait for base to be created
	
	print("\n🔍 Testing conveyor for player:", player.Name)
	
	-- Check if base exists
	local base = BaseBuilder.GetBase(player)
	if not base then
		warn("❌ Base not found for player:", player.Name)
		return
	end
	print("✅ Base found:", base.Name)
	
	-- Check if ConveyorStart exists
	local startMarker = base:FindFirstChild("ConveyorStart")
	if not startMarker then
		warn("❌ ConveyorStart marker not found in base!")
		return
	end
	print("✅ ConveyorStart found at position:", startMarker.Position)
	
	-- Check if ConveyorEnd exists
	local endMarker = base:FindFirstChild("ConveyorEnd")
	if not endMarker then
		warn("❌ ConveyorEnd marker not found in base!")
		return
	end
	print("✅ ConveyorEnd found at position:", endMarker.Position)
	
	-- List all children of base
	print("\n📋 Base contains:")
	for _, child in ipairs(base:GetChildren()) do
		print("  -", child.Name, "(" .. child.ClassName .. ")")
	end
	
	print("\n✅ All checks passed! Conveyor should be working.")
	print("⏰ Boxes should spawn every 4 seconds starting now...\n")
end)
