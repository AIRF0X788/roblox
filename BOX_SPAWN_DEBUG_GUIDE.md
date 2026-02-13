# 🐛 Box Spawn Debug Guide

## Problem
Boxes are not spawning on the conveyor belt after 5+ minutes of gameplay.

## Debug Steps

### 1. Open Roblox Studio with Logs

```bash
# Terminal 1: Start Rojo
rojo serve
```

In Roblox Studio:
1. **Open the Output console** (View → Output, or press `F9`)
2. **Clear all logs** (right-click → Clear)
3. **Press F5** to start the game
4. **Watch the Output console carefully**

---

### 2. Expected Logs (Successful Scenario)

When everything works correctly, you should see these logs in order:

```
[Server] Player joining: YourUsername
[Server] ✅ Base created for YourUsername
[BaseBuilder] ✅ Found ConveyorStart for YourUsername at 0, 3, -15
[Server] Starting conveyor for YourUsername
[ConveyorManager] Starting conveyor for YourUsername
[ConveyorManager] Starting spawn loop for YourUsername
[BaseBuilder] ✅ Found ConveyorStart for YourUsername at 0, 3, -15
[ConveyorManager] ✅ Spawned box: Cardboard Box for YourUsername
[BaseBuilder] ✅ Found ConveyorStart for YourUsername at 0, 3, -15
[ConveyorManager] ✅ Spawned box: Green Crate for YourUsername
... (repeats every 4 seconds)
```

---

### 3. Error Scenarios & Diagnosis

#### ❌ Scenario A: "Base not created"
```
[Server] ❌ Failed to create base for YourUsername
```
**Cause**: `BaseBuilder.CreateBase()` returned `nil`  
**Solution**: Check that `Workspace.Bases` folder exists

---

#### ❌ Scenario B: "Bases folder not found"
```
[BaseBuilder] Bases folder not found!
```
**Cause**: The `Bases` folder is missing from Workspace  
**Solution**: The server should create it automatically. Check `init.server.luau` line ~50

---

#### ❌ Scenario C: "ConveyorStart marker not found"
```
[BaseBuilder] ConveyorStart marker not found in base for YourUsername
[ConveyorManager] ConveyorStart not found for YourUsername
```
**Cause**: The `ConveyorStart` part wasn't created in the base  
**Solution**: Check `BaseBuilder.luau` lines 130-138 to verify marker creation

---

#### ❌ Scenario D: "No logs at all after conveyor start"
```
[Server] Starting conveyor for YourUsername
(nothing else)
```
**Cause**: The spawn loop isn't starting or is crashing silently  
**Solution**: Check for Lua errors in the Output console (red text)

---

### 4. Manual Verification

If logs look correct but boxes still don't appear, verify manually:

#### Check Base Structure in Explorer:
```
Workspace
  └─ Bases (Folder)
      └─ Base_YourUsername (Model)
          ├─ Floor (Part)
          ├─ SpawnPoint (Part)
          ├─ ConveyorBelt (Model)
          │   ├─ BeltBase (Part)
          │   ├─ MovingSurface (Part)
          │   ├─ Rail (Part) x2
          │   ├─ ConveyorStart (Part) ✅ GREEN NEON
          │   └─ ConveyorEnd (Part) ✅ RED NEON
          ├─ BrainrotArea (Part)
          └─ ... (other parts)
```

#### Check ConveyorStart Position:
1. Select `ConveyorStart` in Explorer
2. Check **Properties → Position**
3. Should be something like: `(-30, 3, -15)` or similar
4. **NOT** `(0, 0, 0)` or `(1000, 1000, 1000)`

---

### 5. Force Box Spawn (Manual Test)

If nothing works, try forcing a box spawn manually:

1. Open **Command Bar** in Roblox Studio (View → Command Bar)
2. Paste this code:

```lua
local ConveyorManager = require(game.ServerScriptService.Server.Modules.ConveyorManager)
local player = game.Players:GetPlayers()[1]
if player then
    print("Manual spawn test for: " .. player.Name)
    ConveyorManager.StartConveyor(player)
else
    warn("No player found!")
end
```

3. Press **Enter**
4. Check if logs appear and if a box spawns

---

### 6. Configuration Check

Verify game configuration is correct:

```lua
-- Should be in src/shared/Modules/GameConfig.luau
Conveyor = {
    SpawnInterval = 4,          -- seconds between box spawns
    MaxBoxesOnBelt = 8,         -- max boxes at once
    BeltLength = 60,
    BeltWidth = 8,
    BeltHeight = 2,
    BoxSpeed = 10,
},
```

---

### 7. Send Debug Information

If boxes still don't spawn after all these checks, please send:

1. **Complete Output console log** (copy all text)
2. **Screenshot of Explorer** showing `Workspace → Bases → Base_YourUsername`
3. **Screenshot of ConveyorStart Properties** (Position, Size, Parent)
4. **Your Roblox Studio version** (File → About Roblox Studio)

---

## Quick Fixes

### Fix 1: Delete Bases Folder
Sometimes the bases get corrupted. Try:
1. Stop the game (press Shift+F5)
2. Delete `Workspace → Bases` folder
3. Run the game again (F5)
4. The server will recreate all bases

### Fix 2: Restart Roblox Studio
Complete restart:
1. Close Roblox Studio completely
2. Stop `rojo serve` (Ctrl+C)
3. Restart `rojo serve`
4. Reopen Roblox Studio
5. Sync with Rojo plugin
6. Try again (F5)

### Fix 3: Check GameConfig.luau
Verify `SpawnInterval` is not too high:
```lua
-- BAD: boxes spawn every 400 seconds
SpawnInterval = 400

-- GOOD: boxes spawn every 4 seconds
SpawnInterval = 4
```

---

## Contact

If none of these solutions work, please:
1. Provide complete logs from Output console
2. Screenshots of Workspace structure
3. Any red error messages

We'll investigate further!
