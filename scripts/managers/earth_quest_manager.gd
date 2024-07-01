extends Node

signal accepted(_num: int)
signal unlocked(_num: int)
signal failed(_num: int)
signal done(_num: int)

const PLAYER_IMG = preload("res://art/player/player-img.png")
const APO_BAKET_IMG = preload("res://art/npc/apo_baket/apo_baket_img.png")
const BATA_IMG = preload("res://art/npc/bata/bata-img.png")
const RECIPE = preload("res://scenes/quests/quest5/recipe.tscn")
const QUEST_5 = preload("res://scenes/quests/quest5/quest_5.tscn")

var has_active_quest: bool
var lines: Array[String] = []
var pictures: Array[Texture2D] = []
var char_name: Array[String] = []
var lines_counter: int = 0
var active_npc: int

# CONVERSATION BUTTONS
@onready var next_btn = %Next
@onready var back_btn = %Back
@onready var skip_btn = %Skip

@onready var house = $"../Quest/House"
@onready var player = $"../Player/Player"
@onready var conversation_box = $"../CanvasLayer/Conversation"
@onready var action_buttons = $"../CanvasLayer/ActionButtons"
@onready var lines_holder = $"../CanvasLayer/Conversation/MarginContainer/LinesCon/LinesHolderMar/LinesHolder"
@onready var picture = $"../CanvasLayer/Conversation/MarginContainer/LinesCon/Container/Picture"
@onready var character = $"../CanvasLayer/Conversation/MarginContainer/LinesCon/Container/CharName"
@onready var interact = $"../CanvasLayer/ActionButtons/RightButtons/Interact"
@onready var recipe_pos = $"../Quest/RecipePos"
@onready var bounds = $"../Bounds"

# GAME OVER / WHEN HEART -1
@onready var game_over = $"../CanvasLayer/GameOver"
@onready var retry = $"../CanvasLayer/GameOver/MarginContainer/VBoxContainer/HBoxContainer/Retry"
@onready var home = $"../CanvasLayer/GameOver/MarginContainer/VBoxContainer/HBoxContainer/Home"

# RESPAWN POSITION
@onready var pos_1 = $"../RespawnPoints/Pos1"
@onready var pos_2 = $"../RespawnPoints/Pos2"
@onready var pos_3 = $"../RespawnPoints/Pos3"

func _ready():
	game_over.visible = false
	interact_btn(interact, false)
	
	next_btn = get_node("%Next")
	back_btn = get_node("%Back")
	skip_btn = get_node("%Skip")
	
	retry.pressed.connect(on_retry)
	home.pressed.connect(on_home)
	
	unlocked.connect(quest_unlocked)
	accepted.connect(quest_accepted)
	failed.connect(quest_failed)
	done.connect(quest_done)

func buttons_connect():
	next_btn.pressed.connect(on_next_pressed)
	back_btn.pressed.connect(on_back_pressed)
	skip_btn.pressed.connect(on_skip_pressed)

func buttons_disconnect():
	next_btn.pressed.disconnect(on_next_pressed)
	back_btn.pressed.disconnect(on_back_pressed)
	skip_btn.pressed.disconnect(on_skip_pressed)
	
func conversation(panel: PanelContainer, value: bool):
	panel.visible = value

func controls(container: Control, value: bool):
	container.visible = value

func interact_btn(button: TouchScreenButton, value: bool):
	button.visible = value

func line_controller(_pictures: TextureRect):
	_pictures.texture = pictures[lines_counter]
	lines_holder.text = lines[lines_counter]
	character.text = char_name[lines_counter]

func on_interact_pressed():
	player.can_move = false
	
	convo_manager()
	controls(action_buttons, false)
	conversation(conversation_box, true)
	line_controller(picture)

func on_next_pressed():
	lines_counter += 1
	if lines_counter >= lines.size():
		player.can_move = true
		conversation(conversation_box, false)
		controls(action_buttons, true)
		lines_counter = 0
		if Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.UNLOCKED and not has_active_quest:
			Game.QUESTS[active_npc]["status"] = Game.QUEST_STATE.ACCEPTED
			accepted.emit(active_npc)
	else:
		line_controller(picture)

func on_back_pressed():
	lines_counter -= 1
	if lines_counter < 0:
		lines_counter = 0
	else:
		line_controller(picture)

func on_skip_pressed():
	
	convo_manager()
	conversation(conversation_box, false)
	controls(action_buttons, true)
	
	if Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.UNLOCKED and not has_active_quest:
		Game.QUESTS[active_npc]["status"] = Game.QUEST_STATE.ACCEPTED
		accepted.emit(active_npc)
		has_active_quest = true
		
	player.can_move = true

func quest_unlocked(_num: int):
	
	if _num == 3:
		pass
	elif _num == 4:
		pass
	elif _num == 5:
		pass

func quest_accepted(_num: int):
	print_debug("Signal: ", _num,"  PlayerQuestLevel: ", Game.PLAYER_QUEST_LEVEL)
	
	if _num != 3 and _num != 4 and _num != 5:
		return

	if Game.PLAYER_QUEST_LEVEL == 3:
		
		player.lock_shoot = false
		house.enable_collider = false
		house.done.connect(quest_done)
		
	elif Game.PLAYER_QUEST_LEVEL == 4:
		
		var recipe = RECIPE.instantiate()
		recipe.position = recipe_pos.global_position
		get_tree().get_first_node_in_group("QuestItems").add_child(recipe)
		
	elif Game.PLAYER_QUEST_LEVEL == 5:

		var quest_5 = QUEST_5.instantiate()
		quest_5.on_shuffle()
		get_tree().get_first_node_in_group("Canvas").add_child(quest_5)
		action_buttons.visible = false
		
	Game.QUESTS[_num]["status"] = Game.QUEST_STATE.ACCEPTED
	has_active_quest = true

func quest_failed(_num: int):
	if has_active_quest:
		has_active_quest = false
		Game.QUESTS[_num]["status"] = Game.QUEST_STATE.UNLOCKED
		if Game.PLAYER_QUEST_LEVEL == 3:
			house.done.disconnect(quest_done)
		elif Game.PLAYER_QUEST_LEVEL == 4:
			get_tree().get_first_node_in_group("Recipe").queue_free()
			get_tree().get_first_node_in_group("Time").visible = false
		elif Game.PLAYER_QUEST_LEVEL == 5:
			action_buttons.visible = true
	# prevent from doing some actions
	game_over.visible = true
	player.can_move = false
	player.lock_shoot = true

	game_over.title_content = "Retry!"
	# add here if the HP = 0 condition

func quest_done(_num: int):
	if Game.PLAYER_QUEST_LEVEL == _num:
		if _num < 5:
			Game.QUESTS[_num+1]["status"] = Game.QUEST_STATE.UNLOCKED
			
		has_active_quest = false
		Game.PLAYER_QUEST_LEVEL += 1
		Game.QUESTS[_num]["status"] = Game.QUEST_STATE.DONE
		if Game.PLAYER_QUEST_LEVEL == 6:
			action_buttons.visible = true
		unlocked.emit(_num+1)
	
func on_retry():
	if Game.PLAYER_QUEST_LEVEL == 3:
		player.global_position = pos_1.global_position
	elif Game.PLAYER_QUEST_LEVEL == 4:
		player.global_position = pos_2.global_position
	elif Game.PLAYER_QUEST_LEVEL == 5:
		player.global_position = pos_3.global_position
	elif Game.PLAYER_QUEST_LEVEL == 6:
		player.global_position = pos_3.global_position
	player.visible = true
	game_over.visible = false
	player.can_move = true
	
func on_home():
	get_tree().change_scene_to_file("res://scenes/main_scenes/main_menu.tscn")

func on_confirmation():
	pass

func convo_manager():
	lines_counter = 0
	if active_npc == Game.NPCS.APO_BAKET:
		if Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.LOCKED:
			lines = [
				"Hindi ka pa handa para dito!?"
			]
			pictures = [
				APO_BAKET_IMG
			]
			char_name = [
				"apo baket"
			]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.UNLOCKED:
			lines = [
				"Inay, ano ang iyong problema?",
				"Anak, kasalukuyang nasusunog ang mga bahay sa ating bayan",
				"Maraming mga tao ang nangagnailangan ng tulong",
				"Maari mo bang tulungan ang mga taong maapula ang apoy?",
				"Opo inay, gagawin ko po ang aking makakaya!"
			]
			pictures = [
				PLAYER_IMG,
				APO_BAKET_IMG,
				APO_BAKET_IMG,
				APO_BAKET_IMG,
				PLAYER_IMG
			]
			char_name = [
				"DARA",
				"APO BAKET",
				"APO BAKET",
				"APO BAKET",
				"DARA"
			]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.ACCEPTED:
			lines = [
				"Pakitulungang apulahin ang apoy sa mga kabahayan, Anak",
				"Makakaasa po kayo!"
			]
			pictures = [
				APO_BAKET_IMG,
				PLAYER_IMG
			]
			char_name = [
				"APO BAKET",
				"DARA"
			]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.DONE:
			lines = [
				"Inay natulungan ko na po ang mga taong apulahin ang apoy na sumusunog sakanilang mga bahay!",
				"Maraming salamat saiyo anak!",
				"Dahil sa iyong mabuting kalooban maraming tao ang naisalba",
				"Walang anuman po inay!",
				"Tanggapin mo itong resipi na ipinagmamali ng ating bayan!",
				"Ito ang resipi ng Pawa, and pawa ang pagkain na nagmula sa ating bayan.",
				"Malugod ko pong tinatanggap ito inay!"
			]
			pictures = [
				PLAYER_IMG,
				APO_BAKET_IMG,
				APO_BAKET_IMG,
				PLAYER_IMG,
				APO_BAKET_IMG,
				APO_BAKET_IMG,
				PLAYER_IMG
			]
			char_name = [
				"DARA",
				"APO BAKET",
				"APO BAKET",
				"DARA",
				"APO BAKET",
				"APO BAKET",
				"DARA"
			]
	elif active_npc == Game.NPCS.APO_BAKET2:
		if Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.LOCKED:
			lines = [
				"Hindi ka pa handa para dito!"
			]
			pictures = [
				APO_BAKET_IMG
			]
			char_name = [
				"APO BAKET"
			]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.UNLOCKED:
			lines = [
				"Dara hanapin mo ang aking itinatagong resipi",
				"Matatagpuaan mo ang resipi sa mataas na lugar",
				"Gagawin kopo ang aking makakaya inay"
			]
			pictures = [
				APO_BAKET_IMG,
				PLAYER_IMG,
				PLAYER_IMG
			]
			char_name = [
				"APO BAKET",
				"DARA",
				"DARA"
			]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.ACCEPTED:
			lines = [
				"Matatagpuaan mo ang resipi sa mataas na lugar",
				"Gagawin kopo ang aking makakaya inay"
			]
			pictures = [
				APO_BAKET_IMG,
				PLAYER_IMG
			]
			char_name = [
				"APO BAKET",
				"DARA"
			]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.DONE:
			lines = [
				"Inay natagpuan kona po ang resipi na iyong ipinapahanap",
				"Mabuti naman Dara.",
				"Ang resipi naiyan ay ipapamana ko na saiyo",
				"tubig, mani, asukal, mantika, harina at asin ang mga pangunahing sangkap ng resipi ng pawa",
				"Pangalagaan mo ang resipi na iyan dahil iyan ang ipinagmamalaking pagkain ng ating bayan!",
				"Opo inay!",
				"Papahalagahan kopo itong resipi na ito at ipapamana sa susunod na henerasyon."
			]
			pictures = [
				PLAYER_IMG,
				APO_BAKET_IMG,
				APO_BAKET_IMG,
				APO_BAKET_IMG,
				APO_BAKET_IMG,
				PLAYER_IMG,
				PLAYER_IMG
			]
			char_name = [
				"DARA",
				"APO BAKET",
				"APO BAKET",
				"APO BAKET",
				"APO BAKET",
				"DARA",
				"DARA"
			]
	elif active_npc == Game.NPCS.BATA:
		if Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.LOCKED:
			lines = [
				"Hindi ka pa handa para dito!?"
			]
			pictures = [
				BATA_IMG
			]
			char_name = [
				"Bata"
			]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.UNLOCKED:
			lines = [
				"Bata ano ang iyong problema?",
				"Ako po ay nagugutom!",
				"Kahapon pa pong hindi umuuwi ang aking mga magulang galing sa sakahan",
				"Ganoon ba!",
				"Kahabag-habag naman ang iyong dinaranas!",
				"Sandali lamang bata, at hahanapin ko ang mga sangkap ng resipi na aking natanggap kanina."
			]
			pictures = [
				PLAYER_IMG,
				BATA_IMG,
				BATA_IMG,
				PLAYER_IMG,
				PLAYER_IMG,
				PLAYER_IMG
			]
			char_name = [
				"DARA",
				"BATA",
				"BATA",
				"DARA",
				"DARA",
				"DARA"
			]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.ACCEPTED:
			lines = [
				"Mmmm. mukhang masarap po ang inyong ginagawang pawa"
			]
			pictures = [
				BATA_IMG
			]
			char_name = [
				"BATA"
			]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.DONE:
			lines = [
				"Maraming salamat po sa pagkain!",
				"Ito na ata ang pinaka masarap na pawa na aking natikman!",
				"Walang ano man bata",
				"Naway makauwi na ang iyong mga magulang upang ikaw ay hindi na magutom muli!",
				"Maraming salamat po ulit!"
			]
			pictures = [
				BATA_IMG,
				BATA_IMG,
				PLAYER_IMG,
				PLAYER_IMG,
				BATA_IMG
			]
			char_name = [
				"BATA",
				"BATA",
				"DARA",
				"DARA",
				"BATA"
			]
func _on_lola_body_entered(body):
	if body.is_in_group("Player"):
		if Game.PLAYER_QUEST_LEVEL == 3:
			active_npc = Game.NPCS.APO_BAKET
		elif Game.PLAYER_QUEST_LEVEL == 4:
			active_npc = Game.NPCS.APO_BAKET2
		elif Game.PLAYER_QUEST_LEVEL == 6:
			active_npc = 4
		interact_btn(interact, true)
		interact.connect("pressed", on_interact_pressed)
		buttons_connect()

func _on_lola_body_exited(body):
	if body.is_in_group("Player"):
		interact_btn(interact, false)
		interact.disconnect("pressed", on_interact_pressed)
		buttons_disconnect()

func _on_bata_body_entered(body):
	if body.is_in_group("Player"):
		active_npc = Game.NPCS.BATA
		interact_btn(interact, true)
		interact.connect("pressed", on_interact_pressed)
		buttons_connect()

func _on_bata_body_exited(body):
	if body.is_in_group("Player"):
		interact_btn(interact, false)
		interact.disconnect("pressed", on_interact_pressed)
		buttons_disconnect()
