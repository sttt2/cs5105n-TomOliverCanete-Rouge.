extends Area2D

@export_file("*.tscn") var next_scene: String = "res://scenes/level_2.tscn"

var _triggered: bool = false


func _ready() -> void:
	collision_layer = 16
	collision_mask = 1
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if body.is_in_group("player"):
		_triggered = true
		monitoring = false
		TransitionManager.transition_to(next_scene)
