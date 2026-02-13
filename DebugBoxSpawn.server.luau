--[[
	Script de debug temporaire - À placer dans ServerScriptService
	Supprimez-le une fois le problème résolu
]]

local Players = game:GetService("Players")

-- Attendre que le serveur soit prêt
task.wait(5)

print("=== 🔍 DEBUG BOX SPAWN TEST ===")

local function debugPlayer(player)
	print("\n🧪 Testing for player: " .. player.Name)
	
	-- Vérifier que Bases existe
	local basesFolder = game.Workspace:FindFirstChild("Bases")
	if not basesFolder then
		warn("❌ Bases folder not found!")
		return
	end
	print("✅ Bases folder exists")
	
	-- Vérifier que la base du joueur existe
	local base = basesFolder:FindFirstChild("Base_" .. player.Name)
	if not base then
		warn("❌ Base not found for " .. player.Name)
		return
	end
	print("✅ Base exists: " .. base.Name)
	
	-- Vérifier ConveyorStart
	local startMarker = base:FindFirstChild("ConveyorStart")
	if not startMarker then
		warn("❌ ConveyorStart not found!")
		return
	end
	print("✅ ConveyorStart exists at: " .. tostring(startMarker.Position))
	print("   Transparency: " .. startMarker.Transparency)
	print("   Color: " .. tostring(startMarker.BrickColor))
	
	-- Vérifier ConveyorEnd
	local endMarker = base:FindFirstChild("ConveyorEnd")
	if not endMarker then
		warn("❌ ConveyorEnd not found!")
		return
	end
	print("✅ ConveyorEnd exists at: " .. tostring(endMarker.Position))
	
	-- Calculer la distance entre start et end
	local distance = (endMarker.Position - startMarker.Position).Magnitude
	print("📏 Belt length: " .. math.floor(distance) .. " studs")
	
	-- Lister tous les enfants de la base
	print("\n📋 Base contents:")
	for _, child in ipairs(base:GetChildren()) do
		print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
	end
	
	-- Compter les boxes dans le workspace
	task.wait(10)  -- Attendre 10 secondes pour laisser des boxes spawn
	local boxCount = 0
	for _, obj in ipairs(game.Workspace:GetChildren()) do
		if obj.Name:match("^Box_") then
			boxCount = boxCount + 1
			print("📦 Found box: " .. obj.Name .. " at " .. tostring(obj.Position))
		end
	end
	
	if boxCount > 0 then
		print("\n✅ SUCCESS! Found " .. boxCount .. " boxes in workspace")
	else
		print("\n⚠️ WARNING: No boxes found in workspace after 10 seconds")
		print("Check the Output log for ConveyorManager messages")
	end
	
	print("\n✅ All structural checks passed!")
	print("⏰ Boxes should spawn every 4 seconds if ConveyorManager is running\n")
end

-- Test automatique quand un joueur rejoint
Players.PlayerAdded:Connect(function(player)
	task.wait(3)  -- Attendre que la base soit créée
	debugPlayer(player)
end)

-- Test pour les joueurs déjà connectés
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		debugPlayer(player)
	end)
end
