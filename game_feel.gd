extends Node
## Global game-feel effects: hit-stop and screen-shake.
## Register as autoload "GameFeel" in project.godot.

var _shake_camera: Camera2D = null
var _shake_intensity: float = 0.0
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0


func _process(delta: float) -> void:
	if _shake_timer > 0.0:
		_shake_timer -= delta
		if _shake_camera and is_instance_valid(_shake_camera):
			var amount: float = _shake_intensity * (_shake_timer / _shake_duration)
			_shake_camera.offset = Vector2(
				randf_range(-amount, amount),
				randf_range(-amount, amount)
			)
		if _shake_timer <= 0.0 and _shake_camera and is_instance_valid(_shake_camera):
			_shake_camera.offset = Vector2.ZERO


func hit_stop(duration: float = 0.08) -> void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration * 0.05).timeout  # real-time wait
	Engine.time_scale = 1.0


func screen_shake(intensity: float = 4.0, duration: float = 0.2) -> void:
	# Find the active camera automatically
	_shake_camera = get_viewport().get_camera_2d()
	if not _shake_camera:
		return
	_shake_intensity = intensity
	_shake_duration = duration
	_shake_timer = duration
