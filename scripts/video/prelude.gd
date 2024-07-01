extends Control

const SEA_WORLD_PATH = "res://scenes/main_scenes/world_sea.tscn"

func _on_video_stream_player_finished():
	get_tree().change_scene_to_file(SEA_WORLD_PATH)
	
func _on_skip_pressed():
	get_tree().change_scene_to_file(SEA_WORLD_PATH)
