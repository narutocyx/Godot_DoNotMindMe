extends Node

const MAIN = preload("res://scenes/main.tscn")
const LEVEL_MAP = preload("res://scenes/level_map.tscn")

func load_main_scene() -> void:
	get_tree().change_scene_to_packed(MAIN)
	
func load_game_scene() -> void:
	get_tree().change_scene_to_packed(LEVEL_MAP)
