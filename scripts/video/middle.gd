extends Control

const EARTH_WORLD_PATH = "res://scenes/main_scenes/world_earth.tscn"

func _on_video_stream_player_finished():
	get_tree().change_scene_to_file(EARTH_WORLD_PATH)

func _on_skip_pressed():
	get_tree().change_scene_to_file(EARTH_WORLD_PATH)
