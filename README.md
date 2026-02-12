# BrainrotBoxes - Roblox Box Opening Game

A Roblox box-opening tycoon game built with [Rojo](https://rojo.space/docs).

## Game Concept

Spawn in your personal base equipped with a **conveyor belt**. Boxes of varying rarity appear on the belt - buy them before they reach the end or lose them forever! Each box spawns **Brainrots** that generate money over time. Upgrade your base, conveyor, and luck to become the richest player on the leaderboard and complete all collections!

## Features

- **Conveyor Belt System** - Boxes spawn and move along a belt; buy them by clicking before they fall off
- **7 Rarity Tiers** - Common, Uncommon, Rare, Epic, Legendary, Mythic, Secret
- **18 Unique Brainrots** - Each with their own rarity and income rate
- **3 Upgrade Paths** - Base (capacity), Conveyor (speed), Luck (better rarities)
- **7 Collections** - Complete sets of brainrots for massive rewards
- **Live Leaderboard** - Compete with other players for the #1 spot
- **Auto-Save** - Data persists via DataStoreService
- **Full UI System** - HUD, upgrades panel, collections tab, brainrot list, notifications

## Project Structure

```
src/
  server/
    init.server.luau          -- Main server entry point
    Modules/
      RemoteSetup.luau        -- Creates all RemoteEvents/Functions
      DataManager.luau        -- Player data (load/save/CRUD)
      BaseBuilder.luau        -- Physical base creation in workspace
      ConveyorManager.luau    -- Box spawning, movement, purchasing
      BrainrotManager.luau    -- Brainrot visuals + money collection
      UpgradeManager.luau     -- Base/Conveyor/Luck upgrades
      CollectionManager.luau  -- Collection progress tracking
      LeaderboardManager.luau -- Leaderstats + rankings

  client/
    init.client.luau           -- Main client entry point
    Controllers/
      RemoteHelper.luau        -- Easy remote access from client
      PlayerState.luau         -- Local state + change callbacks
    UI/
      UIBuilder.luau           -- UI component factory
      HudUI.luau               -- Top bar (money, brainrots, income)
      UpgradeUI.luau           -- Right-side upgrade panel
      CollectionUI.luau        -- Left-side collections panel
      BrainrotListUI.luau      -- Bottom brainrot inventory
      NotificationUI.luau      -- Floating notifications
      LeaderboardUI.luau       -- Player rankings panel

  shared/
    Modules/
      GameConfig.luau          -- All game data (rarities, boxes, brainrots, upgrades, collections)
      RemoteNames.luau         -- Centralized remote event/function names
      Utils.luau               -- Shared utility functions
```

## Getting Started

### Prerequisites
- [Rojo 7.x](https://github.com/rojo-rbx/rojo)
- Roblox Studio
- VS Code with Rojo extension (optional)

### Build & Sync

```bash
# Build the place file from source
rojo build -o "BrainrotBoxes.rbxlx"

# Start live sync server (for development)
rojo serve
```

Then open the `.rbxlx` file in Roblox Studio and connect via the Rojo plugin.

## Game Balance

| Box | Rarity | Price | Brainrots |
|-----|--------|-------|-----------|
| Cardboard Box | Common | $10 | 1 |
| Green Crate | Uncommon | $50 | 2 |
| Blue Chest | Rare | $200 | 3 |
| Purple Vault | Epic | $750 | 4 |
| Golden Coffer | Legendary | $3,000 | 5 |
| Infernal Case | Mythic | $12,000 | 6 |
| ??? Box | Secret | $50,000 | 8 |

## How to Play

1. **Spawn** in your base - you start with $50
2. **Watch** boxes appear on your conveyor belt
3. **Click** a box to buy it (if you can afford it!)
4. **Brainrots** spawn in your display area and generate money every 5 seconds
5. **Upgrade** your base to hold more brainrots
6. **Upgrade** your conveyor for faster box spawning
7. **Upgrade** your luck for rarer boxes
8. **Sell** brainrots you don't need from the inventory panel
9. **Complete** collections for massive cash rewards
10. **Dominate** the leaderboard!
