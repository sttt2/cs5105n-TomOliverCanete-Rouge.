extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Coyote Time juice element
var coyote_time: float = 0.1
var coyote_timer: float = 0.0

@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_timer -= delta
	else:
		coyote_timer = coyote_time

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0 # prevent double jump

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Animation
	if is_on_floor():
		if direction == 0:
			anim.play("idle")
		else:
			anim.play("run")
	else:
		anim.play("jump")

	move_and_slide()

func die():
	get_tree().reload_current_scene()
