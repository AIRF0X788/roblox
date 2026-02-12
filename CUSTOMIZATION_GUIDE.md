# 🎨 Customization Guide - BrainrotBoxes

This guide explains how to customize images and sounds for your lootbox game.

---

## 🖼️ Customizing Brainrot Images

### Location
All brainrot image IDs are defined in:
```
src/shared/Modules/GameConfig.luau
```

### How to Replace Images

1. **Upload your images to Roblox**:
   - Go to https://create.roblox.com
   - Navigate to "Development Items" → "Images"
   - Upload your image (PNG, JPG, or GIF)
   - Copy the Asset ID (e.g., `123456789`)

2. **Update GameConfig.luau**:
   ```lua
   { 
     Name = "Skibidi Toilet", 
     Rarity = "Common", 
     MoneyPerCycle = 1, 
     ImageId = "rbxassetid://YOUR_ASSET_ID_HERE" 
   },
   ```

3. **Replace each ImageId**:
   - Find the line with `-- REPLACE THIS` comment
   - Change `"rbxassetid://6023426926"` to your own asset ID
   - Example: `"rbxassetid://123456789"`

### Image Recommendations
- **Format**: PNG with transparent background (best)
- **Size**: 512x512 pixels or 1024x1024 pixels
- **Style**: Square aspect ratio works best
- **Content**: Character, icon, or item representing the brainrot

### All Brainrots to Customize
```
Common (4 items):
- Skibidi Toilet
- Baby Gronk
- Grimace Shake
- Ohio Rizz

Uncommon (3 items):
- Sigma Boy
- Fanum Tax
- Mewing Streak

Rare (3 items):
- Gyatt Overlord
- Duke Dennis
- Livvy Dunne Rizz

Epic (3 items):
- Ice Spice Cube
- Kai Cenat Clone
- Sussy Imposter

Legendary (2 items):
- Golden Skibidi
- CameraMan Supreme

Mythic (2 items):
- Titan Speakerman
- Astro Bot Sigma

Secret (1 item):
- The One Piece Rizz God
```

---

## 🔊 Customizing Lootbox Sounds

### Location
Sound IDs are defined in:
```
src/client/UI/LootboxUI.luau
```

### Default Sounds (to replace)
The game currently uses Roblox default sounds as placeholders:

```lua
local SOUNDS = {
    Spin = "rbxasset://sounds/electronicpingshort.wav",   -- Spinning sound
    Stop = "rbxasset://sounds/button.wav",                -- Stop/tick sound
    Reveal = "rbxasset://sounds/victory.wav",             -- Normal reveal
    Rare = "rbxasset://sounds/uuhhh.wav",                 -- Rare item reveal
}
```

### How to Replace Sounds

1. **Upload your sound to Roblox**:
   - Go to https://create.roblox.com
   - Navigate to "Development Items" → "Audio"
   - Upload your audio file (MP3, OGG, or WAV)
   - Wait for moderation approval (can take minutes to hours)
   - Copy the Asset ID

2. **Update LootboxUI.luau**:
   ```lua
   local SOUNDS = {
       Spin = "rbxassetid://YOUR_SPIN_SOUND_ID",
       Stop = "rbxassetid://YOUR_STOP_SOUND_ID",
       Reveal = "rbxassetid://YOUR_REVEAL_SOUND_ID",
       Rare = "rbxassetid://YOUR_RARE_SOUND_ID",
   }
   ```

### Sound Recommendations

#### Spin Sound
- **Purpose**: Plays during the lootbox carousel spin
- **Duration**: 5+ seconds (can loop)
- **Style**: Rolling, spinning, mechanical sound
- **Example**: CS:GO case opening spin sound
- **Volume**: Medium (0.3 default)

#### Stop Sound
- **Purpose**: Plays when the spin stops
- **Duration**: 0.5-1 second
- **Style**: Click, tick, or mechanical stop
- **Example**: CS:GO case stop sound
- **Volume**: Medium (0.5 default)

#### Reveal Sound
- **Purpose**: Plays when showing common/uncommon/rare items
- **Duration**: 1-3 seconds
- **Style**: Success, victory, positive sound
- **Example**: Item reveal fanfare
- **Volume**: Medium (0.5 default)

#### Rare Sound
- **Purpose**: Plays when revealing Legendary+ items
- **Duration**: 2-4 seconds
- **Style**: Epic, dramatic, special fanfare
- **Example**: Legendary item reveal with bass drop
- **Volume**: High (0.7 default)

### Audio File Specifications
- **Format**: MP3 (recommended), OGG, or WAV
- **Bitrate**: 128-192 kbps
- **Max File Size**: 20 MB
- **Sample Rate**: 44.1 kHz or 48 kHz

### Where to Find Free Sounds
- **Freesound.org** - Creative Commons sounds
- **Pixabay** - Royalty-free audio
- **YouTube Audio Library** - Free music and sound effects
- **CS:GO Sound Archives** - For authentic case opening sounds

---

## 🎯 Testing Your Customizations

### Testing Images
1. Open Roblox Studio
2. Run `rojo serve` to sync your code
3. Play-test the game
4. Open a box to see your images in the lootbox animation
5. Check that images load correctly (no broken image icons)

### Testing Sounds
1. Ensure sounds are approved by Roblox moderation
2. Play-test the game
3. Buy a box and listen for:
   - Spin sound during animation
   - Stop sound when landing on item
   - Reveal sound when showing results
   - Rare sound for high-tier items (Legendary+)

### Common Issues

**Images not showing?**
- Check that Asset ID is correct
- Ensure image is approved by Roblox
- Verify format: `"rbxassetid://123456789"`
- Make sure image is public, not private

**Sounds not playing?**
- Wait for Roblox audio moderation approval
- Check Asset ID is correct
- Verify audio is public, not private
- Test volume levels (adjust in LootboxUI.luau)

**Sound cuts off too early?**
- Check file duration matches animation timing
- Adjust `SPIN_DURATION` in LootboxUI.luau if needed

---

## 📝 Quick Reference

### File Locations
```
Images:     src/shared/Modules/GameConfig.luau (line ~60-98)
Sounds:     src/client/UI/LootboxUI.luau (line ~35-40)
```

### Asset ID Format
```lua
"rbxassetid://YOUR_NUMBER_HERE"
```

### Need Help?
- Check Roblox Creator Documentation: https://create.roblox.com/docs
- Roblox DevForum: https://devforum.roblox.com
- Asset moderation status: https://create.roblox.com/dashboard/creations

---

**Happy Customizing!** 🎉

---

## 🎭 Adding 3D Models for Brainrots

### Why Use 3D Models?
Instead of simple colored spheres, you can use actual 3D character models from the Roblox Toolbox to make your Brainrots look awesome!

### How to Find Models

1. **Open Roblox Studio**
2. **Click Toolbox** (View → Toolbox)
3. **Search for models**:
   - "skibidi toilet"
   - "sigma male"
   - "meme character"
   - "funny character"
   - "brainrot"
   - Or any character name from your Brainrot list

### Adding Models to Your Game

#### Method 1: Use Asset IDs (Recommended)
1. Find a model in Toolbox
2. Right-click → "Copy Asset ID"
3. Open `GameConfig.luau`
4. Replace `ModelId = "rbxassetid://0"` with your Asset ID
5. Example: `ModelId = "rbxassetid://123456789"`

#### Method 2: Insert Directly
1. Drag model from Toolbox into Workspace
2. Place in ServerStorage folder called "BrainrotModels"
3. Name it exactly as the Brainrot name (e.g., "Skibidi Toilet")
4. The game will automatically use it

### Model Requirements
- **Size**: Ideally 2-4 studs tall
- **Anchored**: Should be unanchored (game will anchor it)
- **PrimaryPart**: Should have a PrimaryPart set
- **No scripts**: Remove any scripts from the model

### Recommended Free Models
Search Toolbox for these terms:
- "skibidi toilet model"
- "among us character"
- "roblox avatar"
- "sigma male"
- "meme face"

---

## 💰 Manual Money Collection System

### How It Works
Instead of automatic money, players must click the **Money Collector** in their base to collect earnings from their Brainrots.

### Money Collector Location
- **Yellow glowing platform** in the corner of each base
- **Sign displays**: "💰 MONEY COLLECTOR"
- **Shows pending amount**: "Click to collect: $XXX"

### For Players
1. Brainrots generate money over time
2. Money accumulates (not auto-collected)
3. Walk to the Money Collector platform
4. Click it to collect all pending money
5. Money is added to your balance

### Advantages
- More interactive gameplay
- Players must manage their base
- Creates strategic timing decisions
- More satisfying to see money pile up

---

## 🔧 Advanced Customization

### Changing Money Collection Rate
Open `GameConfig.luau` and find:
```lua
GameConfig.MoneyCollectionInterval = 5  -- seconds between earnings
```
Change `5` to any number of seconds you want.

### Changing Brainrot Spawn Positions
In `BrainrotManager.luau`, adjust these values:
```lua
local offsetX = math.random(-20, 20)  -- Horizontal spread
local offsetZ = math.random(-12, 12)  -- Depth spread
```

### Adding Animations to Models
If your 3D model has animations:
1. The model should have a Humanoid
2. Animations will play automatically
3. Or add custom animation IDs in BrainrotManager

---

## 🎵 Finding CS:GO Sounds

### Where to Get CS:GO Sounds

#### Option 1: Roblox Library
1. Open Roblox Studio
2. Toolbox → Audio
3. Search: "cs go case opening"
4. Search: "lootbox spin"
5. Search: "roulette"
6. Preview and insert into game

#### Option 2: Upload Your Own
1. Download CS:GO sounds from:
   - YouTube (use youtube-dl)
   - Freesound.org (search "csgo")
   - CS:GO sound packs online
2. Convert to MP3 (max 20MB)
3. Upload to Roblox Create
4. Wait for approval
5. Use Asset ID in LootboxUI.luau

### Recommended Sound Types

**Spin Sound**:
- CS:GO case spin loop
- Roulette wheel spinning
- Duration: 5+ seconds
- Loopable

**Stop Sound**:
- Click/tick sound
- Case lock sound
- Duration: 0.5-1 second

**Reveal Sound**:
- Item drop sound
- Success fanfare
- Duration: 1-3 seconds

**Rare Sound**:
- Knife drop sound
- Special item reveal
- Duration: 2-4 seconds
- Epic/dramatic

### Popular CS:GO Sound Asset IDs
(Search these in Roblox Toolbox):
- "csgo case opening sound"
- "csgo knife sound"
- "csgo rare drop"

---

## 🧪 Testing Your Customizations

### Test Checklist
- [ ] All images load in lootbox animation
- [ ] All sounds play correctly
- [ ] 3D models spawn in base
- [ ] Models are correct size (not too big/small)
- [ ] Money Collector works (click to collect)
- [ ] Pending money displays correctly
- [ ] Brainrots don't overlap too much
- [ ] Animation stops on correct item

### Common Issues

**3D Models Not Showing?**
- Check ModelId is correct format
- Ensure model exists in Library
- Check model isn't private
- Try Method 2 (ServerStorage)

**Models Too Big/Small?**
- Edit model in Studio
- Use Scale tool
- Resize to 2-4 studs tall
- Re-upload to Roblox

**Money Collector Not Working?**
- Check ClickDetector exists
- Verify MaxActivationDistance (should be 20)
- Ensure platform is visible
- Check server logs for errors

---

**Need More Help?**
- Roblox DevForum: https://devforum.roblox.com
- Roblox Creator Docs: https://create.roblox.com/docs
- Tutorial Videos: Search "Roblox model customization"

