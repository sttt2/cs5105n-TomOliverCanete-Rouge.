# Rouge Visual Polish & HUD Completion Guide

## Current State
- ✅ Player combat (attack, hurt, death animations + hitbox)
- ✅ Enemy AI (patrol, chase, attack, hurt, death)
- ✅ Core gameplay loop functional
- ❌ Tileset terrain autotiling incomplete
- ❌ Level layering (Background/Ground/Foreground) not restructured
- ❌ HUD & health bar UI missing
- ❌ Parallax background inverted (sky on top)

---

## Task 1: Fix Parallax Background (5 min)
**File:** `scenes/level_1.tscn` and `scenes/level_2.tscn`

**Problem:** ParallaxLayer nodes render in wrong order. Layer5 (cyan sky) draws last, covering Layer1–Layer4 (trees/mountains).

**Fix:**
1. In Godot Editor, open `scenes/level_1.tscn`
2. Select `ParallaxBackground` node
3. **Reorder children** (drag in Scene tree):
   - Layer5 → move to top (renders first, furthest back)
   - Layer4, Layer3, Layer2, Layer1 → follow in order
   - Result order: Layer5, Layer4, Layer3, Layer2, Layer1 (top to bottom in Scene tree = back to front in render)
4. Verify: Sky should be behind trees
5. **Repeat for `level_2.tscn`**

---

## Task 2: Build Tileset with Terrain Autotiling (10 min)
**File:** `scripts/build_tileset.gd` (already created)

**Steps:**
1. Open Godot Editor, go to FileSystem panel
2. Navigate to `res://scripts/build_tileset.gd`
3. Right-click → **Run** (or double-click)
   - This regenerates `tilesets/platformer_tileset.tres` with:
     - Terrain set "Grass Terrain" with 3×3 minimal peering bits
     - Physics collisions on solid tiles (grass top, dirt body, platforms)
     - All texture sources (Floor, Other, Decor, BG Dirt, House)
4. Verify: Open `res://tilesets/platformer_tileset.tres` in Inspector—should see Terrain Set with peering bits configured
5. **Restart project** to reload tileset cache

---

## Task 3: Restructure Level with Multi-Layer TileMapLayers (15 min)
**Files:** `scenes/level_1.tscn`, `scenes/level_2.tscn`

Replace the current single `Ground` + `Decor` with:

### Layer 1: Background_Decor (z_index = -1)
- **Purpose:** Distant background (houses, large trees, background dirt walls, tents)
- **Collision:** Disabled (`collision_enabled = false`)
- **Tiles to use:** `House Tiles.png` (source 4), `BG Dirt1.png` (source 3), `Decor.png` (source 2, large objects)
- **Placement:** Place 1–2 house tiles near level start, background dirt behind walkable area, trees far back

### Layer 2: Ground_Collision (z_index = 0)
- **Purpose:** Main walkable terrain with collision
- **Collision:** Enabled (`collision_enabled = true`)
- **Tiles:** `Floor Tiles1.png` (source 0)
  - Use **grass top tiles** (x 0–2, y 0–2) for surface
  - Use **dirt body tiles** (x 0–2, y 3–5) for underground
  - Use **cliff edge tiles** (x 3–5, y 0–2) for vertical drops
  - Use **platforms** (x 6–8, y 0–2) for floating jump pads
- **Layout:** Create a simple platforming path:
  - Start: grass at y=10 (tiles)
  - Mid: 2–3 floating platforms at y=8–9
  - End: grass platform at y=10 again
  - Underground: solid dirt blocks below walkable area

### Layer 3: Foreground_Decor (z_index = 1)
- **Purpose:** Objects on top of terrain (bushes, tall grass, crates, lanterns)
- **Collision:** Disabled
- **Tiles:** `Decor.png` (source 2, smaller detail sprites)
- **Placement:** Scatter bushes, grass tufts, stone markers, torches around the level for visual interest

### In Godot Editor:
1. Open `scenes/level_1.tscn`
2. Delete existing `Ground` and `Decor` TileMapLayer nodes
3. Create 3 new `TileMapLayer` nodes as children of Level1:
   - Name: `Background_Decor`, z_index: -1, collision_enabled: false, tile_set: platformer_tileset
   - Name: `Ground_Collision`, z_index: 0, collision_enabled: true, tile_set: platformer_tileset
   - Name: `Foreground_Decor`, z_index: 1, collision_enabled: false, tile_set: platformer_tileset
4. **Paint tiles** using the tileset editor:
   - Select each layer, click the tilemap, paint tiles from the palette
   - Use terrain autotiling: painting adjacent grass tiles will auto-blend edges/corners
5. **Align spikes** (`hazards/spike.tscn`): Place spike instances on top of the `Ground_Collision` layer so they sit flush on grass
6. **Repeat for `level_2.tscn`**

---

## Task 4: Create HUD Scene & Health Display (15 min)
**New files to create:**
- `scenes/hud.tscn` (scene)
- `scenes/hud.gd` (script)

### Step 1: Update `player.gd` to emit signal
In `player.gd`, add after line 23 (`@onready var hurtbox`):

```gdscript
signal health_changed(new_health: int, max_health: int)
```

In `player.gd` `_on_hit_received()` (around line 104), after `current_health -= damage`, emit:

```gdscript
health_changed.emit(current_health, max_health)
```

Also emit at start in `_ready()`:

```gdscript
health_changed.emit(current_health, max_health)
```

### Step 2: Create `scenes/hud.gd`

```gdscript
extends CanvasLayer

@onready var health_bar: TextureProgressBar = $HealthBar

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_player_health_changed)
		_on_player_health_changed(player.current_health, player.max_health)

func _on_player_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = float(maximum)
	health_bar.value = float(current)
```

### Step 3: Create `scenes/hud.tscn`
1. In Godot Editor, create new Scene with root node: `CanvasLayer` (name: `HUD`)
2. Attach script: `scenes/hud.gd`
3. Add child: `TextureProgressBar` (name: `HealthBar`)
   - **Texture Under:** `res://assets/hp_bar/GandalfHardcore Hp bar/Hp bar.png`
   - **Texture Progress:** `res://assets/hp_bar/GandalfHardcore Hp bar/red bar.png`
   - **Position:** (16, 16)
   - **Size:** (100, 20)
   - **Min Value:** 0
   - **Max Value:** 100
   - **Step:** 1
4. Save as `scenes/hud.tscn`

### Step 4: Add HUD to Levels
1. Open `scenes/level_1.tscn`
2. Add child instance: `res://scenes/hud.tscn`
3. Repeat for `scenes/level_2.tscn`

---

## Task 5: Test & Verify
1. **Run level_1** (press F5 in editor)
2. **Verify parallax:** Sky behind trees ✓
3. **Verify terrain:** Grass edges blend smoothly, no cutoffs ✓
4. **Verify HUD:** Red health bar visible in top-left, decreases when player takes damage ✓
5. **Verify layers:** Background decor (houses) far back, foreground bushes on top of player ✓
6. **Verify spikes:** Align flush on grass, kill player on contact ✓

---

## File Checklist
- [ ] `scenes/level_1.tscn` — parallax reordered, 3-layer tilemap, HUD added
- [ ] `scenes/level_2.tscn` — parallax reordered, 3-layer tilemap, HUD added
- [ ] `scenes/hud.tscn` — new HUD scene with health bar
- [ ] `scenes/hud.gd` — new HUD script
- [ ] `player.gd` — `health_changed` signal added + emissions
- [ ] `tilesets/platformer_tileset.tres` — regenerated with terrain autotiling (run build_tileset.gd)

---

## Summary
This guide provides a complete manual workflow to finish the visual polish without code generation. Each task is independent and can be done in the Godot Editor UI. Total time: ~45 minutes.
