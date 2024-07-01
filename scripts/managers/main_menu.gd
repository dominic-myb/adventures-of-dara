extends Control

const PRELUDE = "res://scenes/main_scenes/video/prelude.tscn"

@onready var sfx = $Music
@onready var bg = $PanelContainer
@onready var settings = $Settings
@onready var back = $Settings/Back

func _ready():
	bg.visible = false
	settings.visible = false
	back.connect("pressed", on_back_pressed)
	sfx.play()

func _on_play_pressed():
	get_tree().change_scene_to_file(PRELUDE)

func _on_options_pressed():
	bg.visible = true
	settings.visible = true

func _on_quit_pressed():
	Utils.saveGame()
	get_tree().quit()

func _on_sfx_finished():
	sfx.play()

func on_back_pressed():
	bg.visible = false
	settings.visible = false

func _on_master_value_changed(value):
	volume(0, value)

func _on_music_value_changed(value):
	volume(1, value)

func _on_sound_fx_value_changed(value):
	volume(2, value)

func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, value)
