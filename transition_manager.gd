extends CanvasLayer

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var rect: ColorRect = $ColorRect

var _busy: bool = false


func _ready() -> void:
	rect.color = Color(0, 0, 0, 0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func transition_to(scene_path: String) -> void:
	if _busy:
		return
	if scene_path.is_empty():
		return
	_busy = true
	anim.play("fade_to_black")
	await anim.animation_finished
	get_tree().change_scene_to_file(scene_path)
	anim.play("fade_to_normal")
	await anim.animation_finished
	_busy = false
