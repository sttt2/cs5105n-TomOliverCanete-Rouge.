extends CharacterBody2D

enum State { IDLE, RUN, JUMP, ATTACK, HURT, DEATH }

signal health_changed(current: int, max: int)

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var max_fall_speed: float = 600.0
@export var coyote_time: float = 0.1
@export var jump_buffer: float = 0.1
@export var max_health: int = 100

var current_health: int = 100
var current_state: State = State.IDLE
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var facing_direction: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var hitbox: HitboxComponent = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hurtbox: HurtboxComponent = $Hurtbox


func _ready() -> void:
	add_to_group("player")
	current_health = max_health
	hurtbox.hit_received.connect(_on_hit_received)
	anim.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	if current_state == State.DEATH:
		return

	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)  # ponytail: cap fall speed to prevent tunneling
		coyote_timer -= delta
	else:
		coyote_timer = coyote_time

	match current_state:
		State.IDLE, State.RUN, State.JUMP:
			_handle_movement(delta)
			_handle_attack_input()
		State.ATTACK:
			# Decelerate slightly during attack
			velocity.x = move_toward(velocity.x, 0.0, speed * 2.0 * delta)
		State.HURT:
			# Decelerate during hurt knockback
			velocity.x = move_toward(velocity.x, 0.0, speed * 3.0 * delta)

	move_and_slide()
	_update_animation()


func _handle_movement(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer
	else:
		jump_buffer_timer -= delta

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		coyote_timer = 0.0
		jump_buffer_timer = 0.0

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
		facing_direction = -1 if direction < 0.0 else 1
		sprite.flip_h = direction < 0.0
		hitbox_shape.position.x = 12.0 * facing_direction
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)

	if not is_on_floor():
		current_state = State.JUMP
	elif not is_zero_approx(direction):
		current_state = State.RUN
	else:
		current_state = State.IDLE


func _handle_attack_input() -> void:
	if Input.is_action_just_pressed("attack") and is_on_floor():
		current_state = State.ATTACK
		anim.play("attack")


func _update_animation() -> void:
	match current_state:
		State.IDLE:
			anim.play("idle")
		State.RUN:
			anim.play("run")
		State.JUMP:
			anim.play("jump")
		State.HURT:
			anim.play("hurt")


func _on_hit_received(damage: int, source: Node2D, knockback: float) -> void:
	if current_state == State.DEATH:
		return

	current_health -= damage
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		die()
		return

	current_state = State.HURT
	var kb_dir := 1.0
	if source:
		kb_dir = 1.0 if source.global_position.x < global_position.x else -1.0
	velocity.x = kb_dir * knockback
	velocity.y = -100.0
	anim.play("hurt")


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack" or anim_name == "hurt":
		current_state = State.IDLE
	elif anim_name == "death":
		get_tree().reload_current_scene()


func die() -> void:
	if current_state == State.DEATH:
		return
	current_state = State.DEATH
	velocity = Vector2.ZERO
	anim.play("death")
