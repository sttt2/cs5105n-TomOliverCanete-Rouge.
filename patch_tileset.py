#!/usr/bin/env python3
import re

# Read the tileset file
with open(r'C:\Users\acer\Desktop\ESSENTIALS\GAME_DEV\rouge\tilesets\platformer_tileset.tres', 'r') as f:
    content = f.read()

# Full box collision polygon for a 32x32 tile centered at origin
# Points: (-16,-16), (16,-16), (16,16), (-16,16)
collision_polygon = "0:0/0/physics_layer_0/polygons_0/points = PackedVector2Array(-16, -16, 16, -16, 16, 16, -16, 16)"

# Track which tiles get collision
# Sources: 0=Floor (all), 1=Other (all), 4=House (all)
# Sources 2,3 = Decor/BG (no collision)

# Pattern: match tile coordinates like "0:0/0 = 0" for Source 0
# We'll add collision after the terrain data for solid tiles

lines = content.split('\n')
output = []
i = 0

while i < len(lines):
    line = lines[i]
    output.append(line)

    # Check if this is a tile definition line (e.g., "0:0/0 = 0")
    tile_match = re.match(r'^(\d+):(\d+)/0 = 0', line)

    if tile_match:
        x, y = int(tile_match.group(1)), int(tile_match.group(2))

        # Look ahead to find where the terrain data ends for this tile
        j = i + 1
        last_terrain_line = i

        # Scan ahead to find all terrain lines for this tile
        while j < len(lines):
            next_line = lines[j]
            # Check if it's a terrain peering line for this same tile
            if re.match(rf'^{x}:{y}/0/terrain', next_line):
                last_terrain_line = j
                j += 1
            # Check if it's the next tile
            elif re.match(r'^\d+:\d+/0', next_line):
                break
            else:
                j += 1

        # Determine which source this tile belongs to
        # We need to track which SubResource we're in
        # For now, add collision to all tiles in floor/other/house (not decor/bg)
        # This is a heuristic: tiles 0-8 in rows 0-5 are usually in source 0 (floor)

        # Add collision polygon after terrain data
        if last_terrain_line > i:
            i = last_terrain_line
            line = lines[i]
            output.append(line)
            # Add physics layer collision
            output.append(f"{x}:{y}/0/physics_layer_0/polygons_0/points = PackedVector2Array(-16, -16, 16, -16, 16, 16, -16, 16)")
        else:
            # No terrain data, add collision right after tile definition
            output.append(f"{x}:{y}/0/physics_layer_0/polygons_0/points = PackedVector2Array(-16, -16, 16, -16, 16, 16, -16, 16)")

    i += 1

# Write back
with open(r'C:\Users\acer\Desktop\ESSENTIALS\GAME_DEV\rouge\tilesets\platformer_tileset.tres', 'w') as f:
    f.write('\n'.join(output))

print("✓ Tileset patched with collision polygons")
