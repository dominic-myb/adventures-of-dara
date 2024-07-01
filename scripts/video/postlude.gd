extends Control

const MAIN_MENU_PATH = "res://scenes/main_scenes/main_menu.tscn"

func _on_video_stream_player_finished():
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

func _on_skip_pressed():
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
