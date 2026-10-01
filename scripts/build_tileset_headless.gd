extends SceneTree

func _init() -> void:
	# Load existing tileset
	var ts = load("res://tilesets/platformer_tileset.tres") as TileSet

	if not ts:
		print("ERROR: Could not load tileset")
		quit()
		return

	# Full box collision
	var pts = PackedVector2Array([
		Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)
	])

	# Iterate through all sources
	for source_id in ts.get_source_count():
		var src = ts.get_source(source_id)
		if src is TileSetAtlasSource:
			# For decorative sources (2, 3), skip collision
			if source_id == 2 or source_id == 3:
				continue

			# Add physics layer if not present
			if src.get_physics_layers_count() == 0:
				src.add_physics_layer()

			# Add collision to all tiles
			var size = src.get_atlas_grid_size()
			for y in range(size.y):
				for x in range(size.x):
					var coord = Vector2i(x, y)
					if src.has_tile(coord):
						var td = src.get_tile_data(coord, 0)
						if td:
							# Only add collision if not already present
							if td.get_collision_polygons_count(0) == 0:
								td.add_collision_polygon(0)
								td.set_collision_polygon_points(0, 0, pts)

	# Ensure tileset has physics layer 0
	if ts.get_physics_layers_count() == 0:
		ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 1)

	ResourceSaver.save(ts, "res://tilesets/platformer_tileset.tres")
	print("✓ Tileset updated with full box collisions on all solid tiles")
	quit()
