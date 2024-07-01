extends Node

const SAVE_PATH = "user://"
const SAVE_NAME = "savegame.json"

# PLAYER_ATTRIB
var player_mana = 0
var player_max_mana = 100
var player_damage = 2 
var player_movespeed : float = 600.00 
var player_mana_regen_rate : float 
var PLAYER_QUEST_LEVEL : int = 0
var player_pos : Vector2 = Vector2.ZERO
enum QUEST_STATE{
	LOCKED, UNLOCKED, ACCEPTED, DONE
}

enum NPCS{
	DALAG, PAWIKAN, KABIBE, APO_BAKET, APO_BAKET2, BATA
}

var QUESTS = {
	NPCS.DALAG:{
		"status": QUEST_STATE.UNLOCKED,
	},
	NPCS.PAWIKAN:{
		"status": QUEST_STATE.LOCKED,
	},
	NPCS.KABIBE:{
		"status": QUEST_STATE.LOCKED,
	},
	NPCS.APO_BAKET:{
		"status": QUEST_STATE.LOCKED,
	},
	NPCS.APO_BAKET2:{
		"status": QUEST_STATE.LOCKED,
	},
	NPCS.BATA:{
		"status": QUEST_STATE.LOCKED,
	}
}

func _ready():
	player_mana = player_max_mana

func _process(delta):
	player_mana_regen_rate = delta

func saveGame():
	var file = FileAccess.open(SAVE_PATH + SAVE_NAME, FileAccess.WRITE)
	var saved_data = {}
	saved_data["player_pos_x"] = Game.player_pos.x
	saved_data["player_pos_y"] = Game.player_pos.y
	saved_data["QUESTS"] = Game.QUESTS
	var json = JSON.stringify(saved_data)
	file.store_string(json)
	file.close()

func loadGame():
	var file = FileAccess.open(SAVE_PATH + SAVE_NAME, FileAccess.READ)
	var json = file.get_as_text()
	var saved_data = JSON.parse_string(json)
	Game.player_pos.x = saved_data["player_pos_x"]
	Game.player_pos.y = saved_data["player_pos_y"]
	Game.QUESTS = saved_data["QUESTS"]
	file.close()
