# 🔍 Instructions de Debug - Boxes ne Spawnent Pas

## Étape 1 : Vérifier la Console de Roblox Studio

1. Ouvrir Roblox Studio
2. Charger votre jeu avec `rojo serve`
3. Cliquer sur **View** → **Output** (pour voir la console)
4. Jouer en mode test (F5)
5. Observer les messages dans Output

## Messages à chercher :

### ✅ Messages de Succès (tout va bien) :
```
[BaseBuilder] Found ConveyorStart for NomJoueur at Vector3(x, y, z)
[ConveyorManager] Spawned box: Cardboard Box for player: NomJoueur at position: Vector3(x, y, z)
```

### ❌ Messages d'Erreur Possibles :

#### Erreur 1 : Bases folder manquant
```
[BaseBuilder] Bases folder not found in Workspace!
```
**Solution** : Le dossier Bases n'existe pas dans Workspace.
- Vérifier que `init.server.luau` crée bien le dossier Bases
- Relancer le jeu

#### Erreur 2 : Base du joueur introuvable
```
[BaseBuilder] Base not found for player: NomJoueur
```
**Solution** : La base du joueur n'a pas été créée
- Vérifier que `BaseBuilder.CreateBase(player)` est appelé
- Vérifier que le nom du modèle est "Base_NomJoueur"

#### Erreur 3 : ConveyorStart marker manquant
```
[BaseBuilder] ConveyorStart marker not found in base for player: NomJoueur
```
**Solution** : Le marker ConveyorStart n'existe pas dans la base
- Ouvrir **Explorer** dans Roblox Studio
- Naviguer : Workspace → Bases → Base_VotreNom
- Vérifier qu'il existe un Part nommé "ConveyorStart" (vert fluo)

#### Erreur 4 : Pas de conveyor data
```
[ConveyorManager] No conveyor data for player: NomJoueur
```
**Solution** : Le système de conveyor n'a pas démarré
- Vérifier que `ConveyorManager.StartConveyor(player)` est appelé
- Relancer le jeu

## Étape 2 : Vérifier la Structure dans Explorer

Dans Roblox Studio, ouvrir l'onglet **Explorer** et vérifier :

```
Workspace
├── Bases (Folder) ← DOIT EXISTER
│   └── Base_VotreNom (Model)
│       ├── Floor (Part)
│       ├── SpawnPoint (Part - vert)
│       ├── ConveyorBelt (Model)
│       │   ├── BeltBase (Part)
│       │   ├── MovingSurface (Part)
│       │   └── Rails... (Parts)
│       ├── ConveyorStart (Part - vert fluo) ← CRUCIAL
│       ├── ConveyorEnd (Part - rouge)
│       ├── BrainrotArea (Part)
│       └── ...
├── Brainrots (Folder)
└── Map (Model)
```

## Étape 3 : Vérifier Manuellement les Positions

Si tout existe mais les boxes ne spawnent toujours pas :

1. Dans Explorer, sélectionner **Workspace → Bases → Base_VotreNom → ConveyorStart**
2. Dans **Properties**, noter la **Position** (ex: `25, 3, -15`)
3. Dans la console Output, comparer avec les logs
4. Si les positions sont très éloignées (ex: `1000, 1000, 1000`), c'est un problème de calcul de position

## Étape 4 : Test Manuel de Spawn

Pour forcer le spawn d'une box manuellement :

1. Ouvrir la **Command Bar** (View → Command Bar)
2. Coller ce code :
```lua
local ConveyorManager = require(game.ServerScriptService.Server.Modules.ConveyorManager)
local player = game.Players:GetPlayers()[1]
ConveyorManager.StartConveyor(player)
```
3. Appuyer sur Entrée
4. Observer si une box apparaît après 4 secondes

## Étape 5 : Informations à me Fournir

Si le problème persiste, envoyez-moi :

1. **Screenshot de la console Output** (avec tous les messages)
2. **Screenshot de l'Explorer** montrant :
   - Workspace → Bases
   - Le contenu de Base_VotreNom
3. **Position de ConveyorStart** (dans Properties)
4. **Votre nom de joueur** dans Roblox

## Solutions Rapides

### Solution 1 : Recréer les Bases
Si la structure est cassée :
1. Dans Explorer, supprimer le dossier **Bases**
2. Relancer le jeu (F5)
3. Le dossier sera recréé automatiquement

### Solution 2 : Vérifier GameConfig
Si les boxes ne spawnent jamais :
```lua
-- Dans src/shared/Modules/GameConfig.luau
-- Vérifier ces valeurs :
Conveyor = {
    SpawnInterval = 4,  -- Devrait être 4 secondes
    MaxBoxesOnBelt = 8,
    -- ...
}
```

### Solution 3 : Restart Complet
1. Fermer Roblox Studio
2. Arrêter `rojo serve`
3. Redémarrer `rojo serve`
4. Réouvrir Roblox Studio
5. Tester à nouveau

## Contact

Si aucune de ces solutions ne fonctionne, copiez les messages d'erreur de la console et envoyez-les moi !
