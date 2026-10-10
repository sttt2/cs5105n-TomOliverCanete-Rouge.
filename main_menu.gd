extends Control

@onready var continue_btn: Button = $VBoxContainer/ContinueBtn

func _ready() -> void:
	# Enable/Disable continue based on save file existing
	if has_node("/root/SaveManager"):
		var sm = get_node("/root/SaveManager")
		continue_btn.disabled = not FileAccess.file_exists(sm.SAVE_PATH)


func _on_new_game_btn_pressed() -> void:
	# Ensure fresh start logic
	if has_node("/root/SaveManager"):
		var sm = get_node("/root/SaveManager")
		sm.current_save_data["current_health"] = 100
		sm.current_save_data["scene_path"] = "res://scenes/level_1.tscn"

	if has_node("/root/TransitionManager"):
		get_node("/root/TransitionManager").transition_to("res://scenes/level_1.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/level_1.tscn")


func _on_continue_btn_pressed() -> void:
	if has_node("/root/SaveManager"):
		var sm = get_node("/root/SaveManager")
		if sm.load_game():
			if has_node("/root/TransitionManager"):
				get_node("/root/TransitionManager").transition_to(sm.current_save_data["scene_path"])
			else:
				get_tree().change_scene_to_file(sm.current_save_data["scene_path"])
