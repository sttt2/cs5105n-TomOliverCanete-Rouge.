extends CharacterBody2D

enum State { PATROL, CHASE, ATTACK, HURT, DEATH }

const PATROL_SPEED := 40.0
const CHASE_SPEED := 70.0
const ATTACK_RANGE := 24.0

@export var max_health: int = 50

var current_health: int = 50
var current_state: State = State.PATROL
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: int = 1
var player_target: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var edge_ray: RayCast2D = $EdgeRay
@onready var wall_ray: RayCast2D = $WallRay
@onready var detection_area: Area2D = $DetectionArea
@onready var hitbox: HitboxComponent = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hurtbox: HurtboxComponent = $Hurtbox


func _ready() -> void:
	add_to_group("enemies")
	current_health = max_health
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	hurtbox.hit_received.connect(_on_hit_received)
	anim.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	if current_state == State.DEATH:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	match current_state:
		State.PATROL:
			_handle_patrol()
		State.CHASE:
			_handle_chase()
		State.ATTACK:
			velocity.x = move_toward(velocity.x, 0.0, 100.0 * delta)
		State.HURT:
			velocity.x = move_toward(velocity.x, 0.0, 200.0 * delta)

	move_and_slide()
	_update_facing()


func _handle_patrol() -> void:
	if is_on_floor():
		if not edge_ray.is_colliding() or wall_ray.is_colliding():
			direction *= -1
			_sync_rays()
		velocity.x = direction * PATROL_SPEED
		anim.play("run")
	else:
		velocity.x = 0.0
		anim.play("idle")


func _handle_chase() -> void:
	if not player_target or not is_instance_valid(player_target):
		current_state = State.PATROL
		return

	var dist := global_position.distance_to(player_target.global_position)
	if dist <= ATTACK_RANGE:
		current_state = State.ATTACK
		velocity.x = 0.0
		anim.play("attack")
		return

	var to_player := (player_target.global_position.x - global_position.x)
	direction = 1 if to_player > 0 else -1
	_sync_rays()

	# Don't walk off ledges while chasing
	if is_on_floor() and not edge_ray.is_colliding():
		velocity.x = 0.0
		anim.play("idle")
		return

	velocity.x = direction * CHASE_SPEED
	anim.play("run")


func _sync_rays() -> void:
	edge_ray.position.x = 10.0 * direction
	wall_ray.target_position.x = 12.0 * direction
	hitbox_shape.position.x = 10.0 * direction


func _update_facing() -> void:
	if current_state != State.DEATH:
		sprite.flip_h = direction < 0


func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_target = body
		if current_state == State.PATROL:
			current_state = State.CHASE


func _on_detection_body_exited(body: Node2D) -> void:
	if body == player_target:
		player_target = null
		if current_state == State.CHASE:
			current_state = State.PATROL


func _on_hit_received(damage: int, source: Node2D, knockback: float) -> void:
	if current_state == State.DEATH:
		return

	current_health -= damage
	if current_health <= 0:
		die()
		return

	current_state = State.HURT
	var kb_dir := 1.0
	if source:
		kb_dir = 1.0 if source.global_position.x < global_position.x else -1.0
	velocity.x = kb_dir * knockback
	velocity.y = -80.0
	anim.play("hurt")


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		if player_target:
			current_state = State.CHASE
		else:
			current_state = State.PATROL
	elif anim_name == "hurt":
		if player_target:
			current_state = State.CHASE
		else:
			current_state = State.PATROL
	elif anim_name == "death":
		queue_free()


func die() -> void:
	if current_state == State.DEATH:
		return
	current_state = State.DEATH
	velocity = Vector2.ZERO
	# Disable collisions on death
	$CollisionShape2D.set_deferred("disabled", true)
	hitbox_shape.set_deferred("disabled", true)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	anim.play("death")
