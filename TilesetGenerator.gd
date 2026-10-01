@tool
extends Node

func _ready():
	generate_tileset()

func generate_tileset():
	var ts = TileSet.new()
	ts.tile_size = Vector2i(32, 32)

	# Add physics layer
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 1)

	# Add terrain set
	ts.add_terrain_set()
	ts.add_terrain(0)
	ts.set_terrain_name(0, 0, "Grass")
	ts.set_terrain_color(0, 0, Color.GREEN)

	# Load textures
	var floor_tex = load("res://assets/platformer/GandalfHardcore FREE Platformer Assets/Floor Tiles1.png")
	var other_tex = load("res://assets/platformer/GandalfHardcore FREE Platformer Assets/Other Tiles1.png")
	var decor_tex = load("res://assets/platformer/GandalfHardcore FREE Platformer Assets/Decor.png")
	var bg_dirt_tex = load("res://assets/platformer/GandalfHardcore FREE Platformer Assets/BG Dirt1.png")
	var house_tex = load("res://assets/platformer/GandalfHardcore FREE Platformer Assets/House Tiles.png")

	var collision_pts = PackedVector2Array([-16, -16, 16, -16, 16, 16, -16, 16])

	# Floor source (all tiles have collision)
	var floor = TileSetAtlasSource.new()
	floor.texture = floor_tex
	floor.texture_region_size = Vector2i(32, 32)
	floor.add_physics_layer()

	for y in range(6):
		for x in range(9):
			floor.create_tile(Vector2i(x, y))
			var td = floor.get_tile_data(Vector2i(x, y), 0)
			td.add_collision_polygon(0)
			td.set_collision_polygon_points(0, 0, collision_pts)

			# Terrain for autotiling
			if x < 3 and y < 3:
				td.terrain_set = 0
				td.terrain = 0

	ts.add_source(floor, 0)

	# Other source
	var other = TileSetAtlasSource.new()
	other.texture = other_tex
	other.texture_region_size = Vector2i(32, 32)
	other.add_physics_layer()

	for y in range(7):
		for x in range(9):
			other.create_tile(Vector2i(x, y))
			var td = other.get_tile_data(Vector2i(x, y), 0)
			td.add_collision_polygon(0)
			td.set_collision_polygon_points(0, 0, collision_pts)

	ts.add_source(other, 1)

	# Decor (no collision)
	var decor = TileSetAtlasSource.new()
	decor.texture = decor_tex
	decor.texture_region_size = Vector2i(32, 32)
	for y in range(17):
		for x in range(13):
			decor.create_tile(Vector2i(x, y))
	ts.add_source(decor, 2)

	# BG (no collision)
	var bg = TileSetAtlasSource.new()
	bg.texture = bg_dirt_tex
	bg.texture_region_size = Vector2i(32, 32)
	for y in range(4):
		for x in range(6):
			bg.create_tile(Vector2i(x, y))
	ts.add_source(bg, 3)

	# House
	var house = TileSetAtlasSource.new()
	house.texture = house_tex
	house.texture_region_size = Vector2i(32, 32)
	house.add_physics_layer()
	for y in range(7):
		for x in range(14):
			house.create_tile(Vector2i(x, y))
			var td = house.get_tile_data(Vector2i(x, y), 0)
			td.add_collision_polygon(0)
			td.set_collision_polygon_points(0, 0, collision_pts)
	ts.add_source(house, 4)

	# Save
	ResourceSaver.save(ts, "res://tilesets/platformer_tileset.tres")
	print("✓ Tileset generated with collisions")
