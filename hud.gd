extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_player_health_changed)
		# Initialize the health bar
		health_bar.max_value = player.max_health
		health_bar.value = player.current_health

func _on_player_health_changed(current: int, max: int) -> void:
	health_bar.max_value = max
	health_bar.value = current
