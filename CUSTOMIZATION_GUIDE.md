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
