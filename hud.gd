extends CanvasLayer

@onready var health_bar: TextureProgressBar = $MarginContainer/VBoxContainer/HealthBar

func _ready() -> void:
	# Week 7 - ensure pivot is centered for tween scale
	health_bar.pivot_offset = health_bar.size / 2.0

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_player_health_changed)
		# Initialize the health bar
		health_bar.max_value = player.max_health
		health_bar.value = player.current_health

func _on_player_health_changed(current: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current

	# Week 7 - Tween for visual scale punch on health change
	var tween = create_tween()
	tween.tween_property(health_bar, "scale", Vector2(1.3, 1.3), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(health_bar, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)
