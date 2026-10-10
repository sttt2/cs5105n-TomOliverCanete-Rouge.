extends Node
## Minimal Save/Load manager (Week 7)

const SAVE_PATH = "user://savegame.cfg"

var current_save_data: Dictionary = {
	"scene_path": "res://scenes/level_1.tscn",
	"current_health": 100
}


func save_game() -> void:
	var config := ConfigFile.new()

	# Scrape current active level and player state if available
	var tree := get_tree()
	if tree.current_scene and tree.current_scene.scene_file_path:
		current_save_data["scene_path"] = tree.current_scene.scene_file_path

	var player = tree.get_first_node_in_group("player")
	if player:
		current_save_data["current_health"] = player.current_health

	config.set_value("Player", "scene_path", current_save_data["scene_path"])
	config.set_value("Player", "current_health", current_save_data["current_health"])

	config.save(SAVE_PATH)
	print("Game saved to: ", SAVE_PATH)


func load_game() -> bool:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		print("No savegame found.")
		return false

	current_save_data["scene_path"] = config.get_value("Player", "scene_path", "res://scenes/level_1.tscn")
	current_save_data["current_health"] = config.get_value("Player", "current_health", 100)
	print("Game loaded from: ", SAVE_PATH)
	return true


func apply_loaded_state() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.current_health = current_save_data["current_health"]
		player.health_changed.emit(player.current_health, player.max_health)
