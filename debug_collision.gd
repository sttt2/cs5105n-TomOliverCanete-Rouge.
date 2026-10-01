extends Node

func _ready() -> void:
	# Debug: Print collision setup
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player:
		print("=== PLAYER COLLISION DEBUG ===")
		print("Player collision_layer: ", player.collision_layer)
		print("Player collision_mask: ", player.collision_mask)
		print("Player position: ", player.global_position)
		print("Player is_on_floor(): ", player.is_on_floor())

	# Find TileMapLayer nodes
	var tilemaps = get_tree().get_nodes_in_group("tilemap")
	for tm in tilemaps:
		if tm is TileMapLayer:
			print("=== TILEMAP: ", tm.name, " ===")
			print("  collision_layer: ", tm.collision_layer)
			print("  collision_mask: ", tm.collision_mask)
			print("  collision_enabled: ", tm.collision_enabled)
			print("  tile_set: ", tm.tile_set)
			if tm.tile_set:
				print("  tileset physics_layer_0 collision_layer: ", tm.tile_set.get_physics_layer_collision_layer(0))
				print("  tileset physics_layer_0 collision_mask: ", tm.tile_set.get_physics_layer_collision_mask(0))

func _physics_process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player and Input.is_action_just_pressed("ui_accept"):
		print("Player velocity: ", player.velocity)
		print("Player is_on_floor(): ", player.is_on_floor())
		print("Player position: ", player.global_position)
