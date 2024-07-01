extends PanelContainer

const MAIN_MENU = "res://scenes/main_scenes/main_menu.tscn"

@onready var options_button = $"../OptionsButton"
@onready var back = $MarginContainer2/HBoxContainer/Back
@onready var home = $MarginContainer2/HBoxContainer/Home

func _ready():
	options_button.pressed.connect(on_pause)
	back.pressed.connect(on_resume)
	home.pressed.connect(on_home)

func on_pause():
	visible = true
	get_tree().paused = true
	
func on_resume():
	visible = false
	get_tree().paused = false
	
func on_home():
	Game.PLAYER_QUEST_LEVEL = 0
	Game.QUESTS = {
	Game.NPCS.DALAG:{
		"status": Game.QUEST_STATE.UNLOCKED,
	},
	Game.NPCS.PAWIKAN:{
		"status": Game.QUEST_STATE.LOCKED,
	},
	Game.NPCS.KABIBE:{
		"status": Game.QUEST_STATE.LOCKED,
	},
	Game.NPCS.APO_BAKET:{
		"status": Game.QUEST_STATE.LOCKED,
	},
	Game.NPCS.APO_BAKET2:{
		"status": Game.QUEST_STATE.LOCKED,
	},
	Game.NPCS.BATA:{
		"status": Game.QUEST_STATE.LOCKED,
	}
}
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU)

func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, value)

func _on_master_value_changed(value):
	volume(0, value)

func _on_music_value_changed(value):
	volume(1, value)

func _on_sound_fx_value_changed(value):
	volume(2, value)
