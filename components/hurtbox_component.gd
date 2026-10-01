extends Area2D
class_name HurtboxComponent

signal hit_received(damage: int, source: Node2D, knockback: float)

@export var is_invincible: bool = false
@export var invincibility_duration: float = 0.4

var _timer: float = 0.0

func _ready() -> void:
	add_to_group("hurtbox")
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if is_invincible:
		_timer -= delta
		if _timer <= 0.0:
			is_invincible = false

func _on_area_entered(area: Area2D) -> void:
	if is_invincible:
		return
	if area is HitboxComponent:
		var hitbox := area as HitboxComponent
		# Don't hit self
		if hitbox.source_node == get_parent():
			return
		is_invincible = true
		_timer = invincibility_duration
		hit_received.emit(hitbox.damage, hitbox.source_node, hitbox.knockback_force)
