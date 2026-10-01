extends Area2D

@export var damage: int = 50
@export var knockback_force: float = 200.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	# Check if it's the player's hurtbox
	if area.is_in_group("hurtbox"):
		var player = area.get_parent()
		if player and player.has_method("_on_hit_received"):
			player._on_hit_received(damage, self, knockback_force)
