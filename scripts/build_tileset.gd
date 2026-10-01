@tool
extends EditorScript

func _run():
	var ts = TileSet.new()
	ts.tile_size = Vector2i(32, 32)

	# Add physics layer
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 2)
	ts.set_physics_layer_collision_mask(0, 0)

	# Add terrain set
	ts.add_terrain_set()
	ts.add_terrain(0)
	ts.set_terrain_name(0, 0, "Grass Terrain")
	ts.set_terrain_color(0, 0, Color.GREEN)

	var floor_tex = load("res://assets/platformer/GandalfHardcore FREE Platformer Assets/Floor Tiles1.png")
	var other_tex = load("res://assets/platformer/GandalfHardcore FREE Platformer Assets/Other Tiles1.png")
	var decor_tex = load("res://assets/platformer/GandalfHardcore FREE Platformer Assets/Decor.png")
	var bg_dirt_tex = load("res://assets/platformer/GandalfHardcore FREE Platformer Assets/BG Dirt1.png")
	var house_tex = load("res://assets/platformer/GandalfHardcore FREE Platformer Assets/House Tiles.png")

	# Source 0: Floor
	var src_floor = TileSetAtlasSource.new()
	src_floor.texture = floor_tex
	src_floor.texture_region_size = Vector2i(32, 32)

	# Setup physics and terrain for the Grass block (Row 0 to 5, Col 0 to 8)
	var full_rect = Rect2(Vector2(-16, -16), Vector2(32, 32))
	var pts = PackedVector2Array([
		Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)
	])

	for y in range(6):
		for x in range(9):
			if (y >= 3 and x > 5 and x < 9) or (y>=3 and x>2 and x<6):
				pass # Just add basic tiles, we won't strictly autotile everything perfectly in script for the custom stuff

			src_floor.create_tile(Vector2i(x, y))
			var td = src_floor.get_tile_data(Vector2i(x, y), 0)

			# Physics for top solid blocks
			if (x < 6 and y < 3) or (y >= 3):
				td.add_collision_polygon(0)
				td.set_collision_polygon_points(0, 0, pts)

	# Manually setup standard 3x3 minimal terrain for Grass (top 3x3 block: x 0..2, y 0..2)
	# (0,0): Top-Left
	_setup_terrain(src_floor, 0, 0, [TileSet.CELL_NEIGHBOR_RIGHT_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE])
	# (1,0): Top
	_setup_terrain(src_floor, 1, 0, [TileSet.CELL_NEIGHBOR_RIGHT_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, TileSet.CELL_NEIGHBOR_LEFT_SIDE])
	# (2,0): Top-Right
	_setup_terrain(src_floor, 2, 0, [TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, TileSet.CELL_NEIGHBOR_LEFT_SIDE])
	# (0,1): Mid-Left
	_setup_terrain(src_floor, 0, 1, [TileSet.CELL_NEIGHBOR_RIGHT_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, TileSet.CELL_NEIGHBOR_TOP_SIDE, TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER])
	# (1,1): Center
	_setup_terrain(src_floor, 1, 1, [TileSet.CELL_NEIGHBOR_RIGHT_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, TileSet.CELL_NEIGHBOR_LEFT_SIDE, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER, TileSet.CELL_NEIGHBOR_TOP_SIDE, TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER])
	# (2,1): Mid-Right
	_setup_terrain(src_floor, 2, 1, [TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, TileSet.CELL_NEIGHBOR_LEFT_SIDE, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER, TileSet.CELL_NEIGHBOR_TOP_SIDE])
	# (0,2): Bottom-Left
	_setup_terrain(src_floor, 0, 2, [TileSet.CELL_NEIGHBOR_RIGHT_SIDE, TileSet.CELL_NEIGHBOR_TOP_SIDE, TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER])
	# (1,2): Bottom
	_setup_terrain(src_floor, 1, 2, [TileSet.CELL_NEIGHBOR_RIGHT_SIDE, TileSet.CELL_NEIGHBOR_LEFT_SIDE, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER, TileSet.CELL_NEIGHBOR_TOP_SIDE, TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER])
	# (2,2): Bottom-Right
	_setup_terrain(src_floor, 2, 2, [TileSet.CELL_NEIGHBOR_LEFT_SIDE, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER, TileSet.CELL_NEIGHBOR_TOP_SIDE])

	ts.add_source(src_floor, 0)

	# Source 1: Other
	var src_other = TileSetAtlasSource.new()
	src_other.texture = other_tex
	src_other.texture_region_size = Vector2i(32, 32)
	for y in range(7):
		for x in range(9):
			src_other.create_tile(Vector2i(x, y))
	ts.add_source(src_other, 1)

	# Source 2: Decor
	var src_decor = TileSetAtlasSource.new()
	src_decor.texture = decor_tex
	src_decor.texture_region_size = Vector2i(32, 32)
	for y in range(17):
		for x in range(13):
			src_decor.create_tile(Vector2i(x, y))
	ts.add_source(src_decor, 2)

	# Source 3: BG Dirt
	var src_bg = TileSetAtlasSource.new()
	src_bg.texture = bg_dirt_tex
	src_bg.texture_region_size = Vector2i(32, 32)
	for y in range(4):
		for x in range(6):
			src_bg.create_tile(Vector2i(x, y))
	ts.add_source(src_bg, 3)

	# Source 4: House
	var src_house = TileSetAtlasSource.new()
	src_house.texture = house_tex
	src_house.texture_region_size = Vector2i(32, 32)
	for y in range(7):
		for x in range(14):
			src_house.create_tile(Vector2i(x, y))
	ts.add_source(src_house, 4)

	ResourceSaver.save(ts, "res://tilesets/platformer_tileset.tres")
	print("Saved perfect tileset.")

func _setup_terrain(src: TileSetAtlasSource, x: int, y: int, bits: Array):
	var td = src.get_tile_data(Vector2i(x, y), 0)
	td.terrain_set = 0
	td.terrain = 0
	for bit in bits:
		td.set_terrain_peering_bit(bit, 0)
