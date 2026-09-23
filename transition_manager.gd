extends CanvasLayer

@onready var anim = $AnimationPlayer
@onready var rect = $ColorRect

func _ready():
	rect.color = Color(0, 0, 0, 0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func transition_to(scene_path: String):
	anim.play("fade_to_black")
	await anim.animation_finished
	get_tree().change_scene_to_file(scene_path)
	anim.play("fade_to_normal")
