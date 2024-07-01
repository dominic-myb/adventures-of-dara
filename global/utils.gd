class_name SaveLoader extends Node
const SAVE_PATH = "user://"
const SAVE_NAME = "savegame.json"

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
	var quests = {}
	for key in saved_data["QUESTS"].keys():
		quests[Game.NPCS[key]] = saved_data["QUESTS"][key]
	
	# Assign the converted dictionary to Game.QUESTS
	Game.QUESTS = quests
	file.close()
