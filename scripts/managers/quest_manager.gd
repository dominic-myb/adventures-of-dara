extends Node

signal pressed
signal unlocked(_num: int)
signal accepted(_num: int)
signal failed(_num: int)
signal done(_num: int)

const QUEST2 = preload("res://scenes/quests/quest2/quest2.tscn")
const PEARL = preload("res://scenes/quests/quest3/pearl.tscn")
const BOULDER = preload("res://scenes/quests/quest1/boulder.tscn")
const PLAYER_IMG = preload("res://art/player/player-img.png")
const DALAG_IMG = preload("res://art/npc//dalag/dalag-pic.png")
const PAWIKAN_IMG = preload("res://art/npc/pawikan/pawikan-pic.png")
const KABIBE_DEF = preload("res://art/npc/kabibe/kabibe_def_img.png")
const KABIBE_DONE = preload("res://art/npc/kabibe/kabibe_done_img.png")
const KABIBE_IDLE = preload("res://art/npc/kabibe/kabibe_idle_img.png")

var next_btn : TextureButton
var back_btn : TextureButton
var skip_btn : TextureButton

var lines_counter : int = 0
var lines : Array[String] = []
var pictures : Array[Texture2D] = []
var char_name: Array[String] = []

var has_active_quest : bool 
var active_npc : int
var on: bool = true

@onready var interact = $"../CanvasLayer/RightButtonContainer/RightButtons/Interact"
@onready var conversation_box = $"../CanvasLayer/Conversation"
@onready var lines_holder = $"../CanvasLayer/Conversation/MarginContainer/LinesCon/MarginContainer/LinesHolder"
@onready var joystick = $"../CanvasLayer/JoystickContainer"
@onready var right_buttons = $"../CanvasLayer/RightButtonContainer"
@onready var picture = $"../CanvasLayer/Conversation/MarginContainer/LinesCon/Container/Picture"
@onready var character = $"../CanvasLayer/Conversation/MarginContainer/LinesCon/Container/CharName"
@onready var quest_items = $"../Player/Player/Basket"
@onready var quest_3 = $"../Quest3"
@onready var quest_notification = $"../CanvasLayer/QuestNotification"

@onready var game_over = $"../CanvasLayer/GameOver"
@onready var retry = $"../CanvasLayer/GameOver/MarginContainer/VBoxContainer/HBoxContainer/Retry"
@onready var home = $"../CanvasLayer/GameOver/MarginContainer/VBoxContainer/HBoxContainer/Home"
@onready var player = $"../Player/Player"

@onready var kabibe = $"../NPC/Kabibe"
@onready var pawikan = $"../NPC/Pawikan"
@onready var dalag = $"../NPC/Dalag"

@onready var pos_1 = $"../RespawinPos/Pos1"
@onready var pos_2 = $"../RespawinPos/Pos2"
@onready var pos_3 = $"../RespawinPos/Pos3"

func _ready():
	
	game_over.visible = false
	next_btn = get_node("%Next")
	back_btn = get_node("%Back")
	skip_btn = get_node("%Skip")
	
	connect("unlocked", quest_unlocked)
	connect("accepted", quest_accepted)
	connect("failed", quest_failed)
	connect("done", quest_done)
	
	retry.pressed.connect(on_retry)
	home.pressed.connect(on_home)
	
"""
START OF BUTTON MANAGER
"""
func buttons_connect():
	next_btn.pressed.connect(on_next_pressed)
	back_btn.pressed.connect(on_back_pressed)
	skip_btn.pressed.connect(on_skip_pressed)

func buttons_disconnect():
	next_btn.pressed.disconnect(on_next_pressed)
	back_btn.pressed.disconnect(on_back_pressed)
	skip_btn.pressed.disconnect(on_skip_pressed)

func on_out_of_range():
	controls(joystick, right_buttons, true)
	conversation(conversation_box, false)
	
func line_controller(_pictures: TextureRect):
	_pictures.texture = pictures[lines_counter]
	lines_holder.text = lines[lines_counter]
	character.text = char_name[lines_counter]
	

func controls(container1: HBoxContainer, container2: HBoxContainer, value: bool):
	container1.visible = value
	container2.visible = value

func conversation(panel: PanelContainer, value: bool):
	panel.visible = value

func interact_btn(btn: TouchScreenButton, value: bool):
	btn.visible = value

func on_interact_pressed():
	player.can_move = false
	convo_manager()
	controls(joystick, right_buttons, false)
	conversation(conversation_box, true)
	line_controller(picture)

func on_next_pressed():
	lines_counter += 1
	if lines_counter >= lines.size():
		player.can_move = true
		conversation(conversation_box, false)
		controls(joystick, right_buttons, true)
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
	controls(joystick, right_buttons, true)
	if Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.UNLOCKED and not has_active_quest:
		Game.QUESTS[active_npc]["status"] = Game.QUEST_STATE.ACCEPTED
		accepted.emit(active_npc)
		has_active_quest = true
	player.can_move = true

"""
START OF QUEST MANAGER
"""
		
func quest_accepted(_num: int):
	print_debug("Signal: ", _num,"  PlayerQuestLevel: ", Game.PLAYER_QUEST_LEVEL)
	if _num != 0 and _num != 1 and _num != 2:
		return

	if Game.PLAYER_QUEST_LEVEL == 0:

		var boulder = BOULDER.instantiate()
		boulder.position = dalag.global_position
		get_tree().get_first_node_in_group("QuestItems").add_child(boulder)

	elif Game.PLAYER_QUEST_LEVEL == 1:
		
		var quest_2 = QUEST2.instantiate()
		var basket = get_tree().get_first_node_in_group("Basket")
		basket.visible = true
		quest_2.global_position = Vector2(2684, -2498)
		get_tree().get_first_node_in_group("QuestItems").add_child(quest_2)

	elif Game.PLAYER_QUEST_LEVEL == 2:

		randomize()
		var random_float = randf()
		var pearl = PEARL.instantiate()
		if random_float < 0.10:
			pearl.position = quest_3.pos_1
		elif random_float < 0.20:
			pearl.position = quest_3.pos_2
		elif random_float < 0.30:
			pearl.position = quest_3.pos_3
		elif random_float < 0.40:
			pearl.position = quest_3.pos_4
		elif random_float < 0.50:
			pearl.position = quest_3.pos_5
		elif random_float < 0.60:
			pearl.position = quest_3.pos_6
		elif random_float < 0.70:
			pearl.position = quest_3.pos_7
		elif random_float < 0.80:
			pearl.position = quest_3.pos_8
		elif random_float < 0.90:
			pearl.position = quest_3.pos_9
		elif random_float < 1.00:
			pearl.position = quest_3.pos_10
		
		get_tree().get_first_node_in_group("QuestItems").add_child(pearl)

	Game.QUESTS[_num]["status"] = Game.QUEST_STATE.ACCEPTED
	has_active_quest = true

func quest_done(_num: int):
	if _num != Game.PLAYER_QUEST_LEVEL:
		print_debug("Signal: ", _num, "  PlayerQuestLevel:", Game.PLAYER_QUEST_LEVEL)
		return
	has_active_quest = false
	Game.PLAYER_QUEST_LEVEL += 1
	Game.QUESTS[_num]["status"] = Game.QUEST_STATE.DONE
	Game.QUESTS[_num + 1]["status"] = Game.QUEST_STATE.UNLOCKED
	Utils.saveGame()
	unlocked.emit(_num + 1)

func quest_failed(_num: int):
	has_active_quest = false
	Game.QUESTS[_num]["status"] = Game.QUEST_STATE.UNLOCKED
	# minus heart
	game_over.visible = true
	player.can_move = false
	Game.player_hp -= 1
	game_over.title_content = "Retry!"
	if Game.player_hp <= 0:
		game_over.title_content = "Game Over!"
		# add here if the HP = 0 condition
	
func on_home():
	pass

func on_retry():
	if Game.PLAYER_QUEST_LEVEL == 0:
		player.global_position = pos_1.global_position
	elif Game.PLAYER_QUEST_LEVEL == 1:
		player.global_position = pos_2.global_position
	elif Game.PLAYER_QUEST_LEVEL == 2:
		player.global_position = pos_3.global_position
	
	player.visible = true
	game_over.visible = false
	player.can_move = true
	if Game.player_hp == 0:
		Game.player_hp = 3


func quest_unlocked(_num: int):
	if Game.PLAYER_QUEST_LEVEL == 0:
		# DALAG
		pass
	elif Game.PLAYER_QUEST_LEVEL == 1:
		# PAWIKAN
		pass
	elif Game.PLAYER_QUEST_LEVEL == 2:
		# PAWIKAN
		pass

func convo_manager():
	lines_counter = 0
	if active_npc == Game.NPCS.DALAG:
		if Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.LOCKED:
				lines = [
					"Hindi ka pa handa para dito!"
				]
				pictures = [
					DALAG_IMG
				]
				char_name = [
					"DALAG"
				]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.UNLOCKED:
			lines = [
				"Kaibigan, saan ka patungo?",
				"At mukhang kaybigat ng iyong dala?",
				"Kaibigan para ito sa aking mahal na ina na may sakit",
				"Kay saklap naman ng sinapit ng iyong ina kaibigan",
				"Oo nga kaibigan.",
				"Kailangan kong dikdikin ang mga batong ito at paghaluhaluin",
				"nang sa gayon ay mapagaling ko ang aking ina.",
				"Mahihirapan ka niyan at pagdating mo sa iyong paroroonan ay...",
				"baka hindi mo na madikdik ang bato at pagod ka na sa iyong paglalakbay, ",
				"atin nang pagtulungan at dikdikin ang mga bato para ipainom sa iyong maysakit na ina"
			]
			pictures = [
				PLAYER_IMG,
				PLAYER_IMG,
				DALAG_IMG,
				PLAYER_IMG,
				DALAG_IMG,
				DALAG_IMG,
				DALAG_IMG,
				PLAYER_IMG,
				PLAYER_IMG,
				PLAYER_IMG
			]
			char_name = [
				"DARA",
				"DARA",
				"DALAG",
				"DARA",
				"DALAG",
				"DALAG",
				"DALAG",
				"DARA",
				"DARA",
				"DARA"
			]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.ACCEPTED:
			lines = [
				"Tulungan mo akong dikdikin ang bato",
				"Tutulungan kita"
			]
			pictures = [
				DALAG_IMG,
				PLAYER_IMG
			]
			char_name = [
				"DALAG",
				"DARA"
			]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.DONE:
			lines = [
				"Maraming salamat, Dara",
				"Walang anuman, humayo ka na para mapainom mo na ng gamot ang iyong ina"
			]
			pictures = [
				DALAG_IMG,
				PLAYER_IMG
			]
			char_name = [
				"DALAG",
				"DARA"
			]
	if active_npc == Game.NPCS.PAWIKAN:
		if Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.LOCKED:
				lines = [
					"Hindi ka pa handa para dito!"
				]
				pictures = [
					PAWIKAN_IMG
				]
				char_name = [
					"PAWIKAN"
				]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.UNLOCKED:
			lines = [
				"Kaibigan ano ang nangyari?",
				"Dahil sa mga basurang bumabagsak galing sa kalupaan lumalala na ang polusyon dito sa ating tahanan",
				"Tama ka kaibigan dahil sa polusyon nagkaroon ng sakit ang aking kaibigan na si Hito",
				"Mabuti nalamang ay nagamot namin siya, at hindi na lumala pa ang kanyang sakit.",
				"Mabuti naman kung ganoon kaibigan",
				"Kaibigan maari mo bang linisin ang mga basurang nalalag mula sa kalupaan.",
				"Oo kaibigan, para sa ikaaayos ng ating tahanan."
			]
			pictures = [
				PLAYER_IMG,
				PAWIKAN_IMG,
				PLAYER_IMG,
				PLAYER_IMG,
				PAWIKAN_IMG,
				PAWIKAN_IMG,
				PLAYER_IMG
			]
			char_name = [
				"DARA",
				"PAWIKAN",
				"DARA",
				"DARA",
				"PAWIKAN",
				"PAWIKAN",
				"DARA"
			]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.ACCEPTED:
			lines = [
				"Maraming salamat, Dara. Malaking tulong ito sa amin.",
				"Walang anuman. Masaya akong makatulong. Sana mas marami pang tao ang magising sa ganitong problema.",
				"Sana nga. Kung magtutulungan ang lahat, mas magiging maganda ang kinabukasan ng ating karagatan.",
				"Tama ka. Sige, tatapusin ko na ang paglilinis dito. Ingat ka, kaibigan!",
				"Maraming salamat ulit. Ingat din at nawa'y maging matagumpay ka sa iyong misyon."
			]
			pictures = [
				PAWIKAN_IMG,
				PLAYER_IMG,
				PAWIKAN_IMG,
				PLAYER_IMG,
				PAWIKAN_IMG
			]
			char_name = [
				"PAWIKAN",
				"DARA",
				"PAWIKAN",
				"DARA",
				"PAWIKAN"
			]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.DONE:
			lines = [
				"Kumusta, kaibigan! Mas mabuti na ang pakiramdam ko ngayon. Salamat sa iyong pagsusumikap. Ang linis na ng karagatan!",
				"Natutuwa akong marinig yan. Mahirap ang quest na ito, pero sulit kapag nakikita kitang masaya.",
				"Malaking bagay ang iyong pagsisikap para sa aming mga nilalang sa dagat. Mas malaya kaming makalangoy at mas ligtas na kami ngayon.",
				"Napakaganda. Patuloy kong gagawin ang aking bahagi para panatilihing malinis ang karagatan.",
				"Salamat! Kung lahat sana ay kasing mapagmalasakit mo, magiging mas maganda ang ating mundo.",
				"Ipapalaganap ko ang mensahe at hihikayatin ang iba na tumulong din. Sama-sama, malaki ang magagawa natin.",
				"Tumpak! Salamat muli, at sana’y madalas kang dumalaw sa amin.",
				"Oo, dadalaw ako. Ingat ka, Pawikan!",
				"Ikaw rin, kaibigan. Paalam!"
			]
			pictures = [
				PAWIKAN_IMG,
				PLAYER_IMG,
				PAWIKAN_IMG,
				PLAYER_IMG,
				PAWIKAN_IMG,
				PLAYER_IMG,
				PAWIKAN_IMG,
				PLAYER_IMG,
				PAWIKAN_IMG
			]
			char_name = [
				"PAWIKAN",
				"DARA",
				"PAWIKAN",
				"DARA",
				"PAWIKAN",
				"DARA",
				"PAWIKAN",
				"DARA",
				"PAWIKAN"
			]
	if active_npc == Game.NPCS.KABIBE:
		if Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.LOCKED:
				lines = [
					"Hindi ka pa handa para dito!"
				]
				pictures = [
					KABIBE_IDLE
				]
				char_name = [
					"KABIBE"
				]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.UNLOCKED:
			lines = [
				"Kaibigan ano ang iyong problema, at mukang kay lungkot mo?",
				"Kaibigan nawawala ang perlas na aking iniingatan, dahil sa bagyo na dumaan.",
				"Ganoon ba kaibigan, nasalanta din ako ng bagyong dumaan.",
				"Namaalam ang aking mahal na ina at ama dahil sa bagyong iyon.",
				"Kay sama pala ng naidulot saiyo ba bagyong iyon kaibigan.",
				"Kaibigan maari mo ba akong tulungan hanapin ang aking nawawalang perlas?",
				"Oo naman kaibigan.",
				"Tayo tayo din naman ang magtutulungan aking kaibigan",
				"Maraming salamat kaibigan",
				"Balikan mo nalang ako dito sa aking lugar pag nahanap mo na ang aking perlas aking kaibigan"
			]
			pictures = [
				PLAYER_IMG,
				KABIBE_DEF,
				PLAYER_IMG,
				PLAYER_IMG,
				KABIBE_DEF,
				KABIBE_DEF,
				PLAYER_IMG,
				PLAYER_IMG,
				KABIBE_DEF,
				KABIBE_DEF
			]
			char_name = [
				"DARA",
				"KABIBE",
				"DARA",
				"DARA",
				"KABIBE",
				"KABIBE",
				"DARA",
				"DARA",
				"KABIBE",
				"KABIBE"
			]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.ACCEPTED:
			lines = [
				"Pakihanap ang aking nawawalang perlas",
				"Tutulungan kita na hanapin!"
			]
			pictures = [
				KABIBE_DEF,
				PLAYER_IMG
			]
			char_name = [
				"KABIBE",
				"DARA"
			]
		elif Game.QUESTS[active_npc]["status"] == Game.QUEST_STATE.DONE:
			lines = [
				"Kaibigan natagpuan ko na ang iyong nawawalang perlas",
				"Maraming salamat sa pag hanap at pag balik mo sa aking nawawalang perlas kaibigan",
				"Walang ano man kaibigan",
				"Sana ikaw ay lumigaya na dahil nahanap mo na ang nawawalang perlas",
				"Ako ay lubos na masaya na kaibigan",
				"Sana ay mapag tagumpayan mo na din ang misyon na naiwan sayo ng iyong mga magulang kaibigan",
				"Ako ay umaasa na mapag tagumpayan ko ang aking misyon kaibigan",
				"Humayo ka na kaibigan at malayo pa ang iyong lalakbayin",
				"Paalam kaibigan",
				"Paalam aking kaibigan"
			]
			pictures = [
				PLAYER_IMG,
				KABIBE_DONE,
				PLAYER_IMG,
				PLAYER_IMG,
				KABIBE_DONE,
				KABIBE_DONE,
				PLAYER_IMG,
				KABIBE_DONE,
				KABIBE_DONE,
				PLAYER_IMG
			]
			char_name = [
				"DARA",
				"KABIBE",
				"DARA",
				"DARA",
				"KABIBE",
				"KABIBE",
				"DARA",
				"KABIBE",
				"KABIBE",
				"DARA"
			]

func _on_pawikan_body_entered(body):
	if body.is_in_group("Player"):
		active_npc = Game.NPCS.PAWIKAN
		interact_btn(interact, true)
		interact.connect("pressed", on_interact_pressed)
		buttons_connect()

func _on_pawikan_body_exited(body):
	if body.is_in_group("Player"):
		interact_btn(interact, false)
		interact.disconnect("pressed", on_interact_pressed)
		buttons_disconnect()

func _on_dalag_body_entered(body):
	if body.is_in_group("Player"):
		active_npc = Game.NPCS.DALAG
		interact_btn(interact, true)
		interact.connect("pressed", on_interact_pressed)
		buttons_connect()

func _on_dalag_body_exited(body):
	if body.is_in_group("Player"):
		on_out_of_range()
		interact_btn(interact, false)
		interact.disconnect("pressed", on_interact_pressed)
		buttons_disconnect()

func _on_kabibe_body_entered(body):
	if body.is_in_group("Player"):
		active_npc = Game.NPCS.KABIBE
		interact_btn(interact, true)
		interact.connect("pressed", on_interact_pressed)
		buttons_connect()

func _on_kabibe_body_exited(body):
	if body.is_in_group("Player"):
		interact_btn(interact, false)
		interact.disconnect("pressed", on_interact_pressed)
		buttons_disconnect()
