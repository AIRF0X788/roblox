# Asset IDs Reference - Roblox Workshop Assets

Ce fichier liste les Asset IDs recommandés pour les Brainrots et modèles 3D.

## 📸 Images de Brainrots (Placeholder → Vrais Assets)

Les images actuelles utilisent `rbxassetid://6023426926` (placeholder).

### 🔍 Comment trouver de vraies images :

1. Ouvrir Roblox Studio
2. Aller dans **Toolbox** → **Marketplace**
3. Chercher : "brain emoji", "face emoji", "meme face", "troll face"
4. Filtrer par **Decals** ou **Images**
5. Copier l'Asset ID

### 🎨 Images populaires Roblox (Examples) :

- **Troll Face** : `rbxassetid://6864086702`
- **Brain Emoji** : `rbxassetid://7229442422`
- **Gigachad Face** : `rbxassetid://8560915887`
- **Pepe Face** : `rbxassetid://6864459854`
- **Wojak Sad** : `rbxassetid://8560932174`
- **Amogus** : `rbxassetid://6376695320`
- **Drake Yes** : `rbxassetid://6864475631`
- **Stonks Face** : `rbxassetid://6864492018`
- **Doge** : `rbxassetid://6376699408`
- **Nyan Cat** : `rbxassetid://6376705752`
- **Patrick Star** : `rbxassetid://6376711094`
- **Shrek Face** : `rbxassetid://6376716436`
- **Sans Undertale** : `rbxassetid://6376721778`
- **Thanos Face** : `rbxassetid://6376727120`
- **Ricardo Milos** : `rbxassetid://6376732462`
- **John Cena** : `rbxassetid://6376737804`
- **Big Chungus** : `rbxassetid://6376743146`
- **Illuminati** : `rbxassetid://6376748488`

## 🎵 Sons CS:GO (Déjà intégrés dans LootboxUI.luau)

- **Spin** : `rbxassetid://160062913` ✅
- **Stop** : `rbxassetid://421058860` ✅
- **Reveal** : `rbxassetid://3398620867` ✅
- **Rare** : `rbxassetid://9125644454` ✅

## 🧊 Modèles 3D de Brainrot (À implémenter)

### 🔍 Comment trouver des modèles 3D :

1. Ouvrir Roblox Studio
2. **Toolbox** → **Marketplace**
3. Chercher : "brain model", "emoji mesh", "character head", "meme model"
4. Filtrer par **Models** ou **Meshes**
5. Insérer dans **ServerStorage** ou copier l'Asset ID

### 🗿 Modèles populaires (Examples) :

- **Brain Model** : `rbxassetid://6378099933`
- **Emoji Sphere** : `rbxassetid://5979859924`
- **Cube Character** : `rbxassetid://6869435859`
- **Floating Head** : `rbxassetid://6869442201`
- **Trophy** : `rbxassetid://6869448543`
- **Diamond** : `rbxassetid://6869454885`
- **Star** : `rbxassetid://6869461227`
- **Crown** : `rbxassetid://6869467569`

## ⚙️ Comment modifier les Asset IDs :

1. **Pour les images** : Modifier `src/shared/Modules/GameConfig.luau`
   ```lua
   ImageId = "rbxassetid://VOTRE_ID_ICI",
   ```

2. **Pour les modèles 3D** : Utiliser `InsertService` dans `BrainrotManager.luau`
   ```lua
   local model = game:GetService("InsertService"):LoadAsset(assetId):GetChildren()[1]
   ```

3. **Pour les sons** : Déjà fait dans `src/client/UI/LootboxUI.luau` ✅

