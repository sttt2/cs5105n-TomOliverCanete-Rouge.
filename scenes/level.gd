extends Node2D

@export var level_id: int = 1
@export var level_width_tiles: int = 32
@export var level_height_tiles: int = 16
@export var fall_death_y: float = 560.0


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player is CharacterBody2D:
		if player.global_position.y > fall_death_y:
			if player.has_method("die"):
				player.die()
