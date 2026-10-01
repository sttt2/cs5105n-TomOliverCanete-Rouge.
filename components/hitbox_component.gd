extends Area2D
class_name HitboxComponent

@export var damage: int = 10
@export var knockback_force: float = 150.0

var source_node: Node2D = null

func _ready() -> void:
	source_node = get_parent() as Node2D
