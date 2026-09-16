extends CharacterBody2D

const SPEED = 50.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 1

@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var edge_ray = $EdgeRay
@onready var wall_ray = $WallRay

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor():
		# Check for edges or walls
		if not edge_ray.is_colliding() or wall_ray.is_colliding():
			direction *= -1
			sprite.flip_h = direction < 0
			edge_ray.position.x = 10 * direction
			wall_ray.target_position.x = 12 * direction

		velocity.x = direction * SPEED
		anim.play("run")
	else:
		velocity.x = 0
		anim.play("idle")

	move_and_slide()
