extends Node2D

const garbage1 = preload("res://scenes/quests/quest2/garbage1.tscn")
const garbage2 = preload("res://scenes/quests/quest2/garbage2.tscn")
const garbage3 = preload("res://scenes/quests/quest2/garbage3.tscn")
const garbage4 = preload("res://scenes/quests/quest2/garbage4.tscn")
const garbage5 = preload("res://scenes/quests/quest2/garbage5.tscn")

var garbage = []
var timeout: bool = false
var in_range: bool = false
var started: bool = false
var speed: float
var garbage_counter: int 
var basket : Area2D
var pawikan : CharacterBody2D
var quest_items: Node2D
var quest_manager: Node

@onready var pos_1 = $SpawnPos1
@onready var pos_2 = $SpawnPos2
@onready var pos_3 = $SpawnPos3
@onready var pos_4 = $SpawnPos4
@onready var border = $QuestArea/Border

@onready var label = $QuestArea/CollisionShape2D/Label
@onready var area_time = $TimeInsideArea
@onready var quest_time = $QuestTime

@onready var col1 = $QuestArea/CollisionShape2D
@onready var col2 = $GarbageDetector/CollisionShape2D

func _ready():
	quest_manager = get_tree().get_first_node_in_group("QuestManager")
	quest_items = get_tree().get_first_node_in_group("QuestItems")
	pawikan = get_tree().get_first_node_in_group("Pawikan")
	basket = get_tree().get_first_node_in_group("Basket")
	
	pos_1.play("default")
	pos_2.play("default")
	pos_3.play("default")
	pos_4.play("default")

func _process(_delta):
	if quest_time.time_left > 0:
		label.text = "%s" % int(quest_time.time_left)
		if is_divisible_by_five(int(quest_time.time_left)):
			garbage = get_tree().get_first_node_in_group("QuestItems").get_children()
			if garbage.size() < 3 and quest_time.time_left > 5 :
				spawn_garbage()
	if not started:
		if not timeout or not in_range:
			label.text = "Get Inside!"
	if area_time and area_time.time_left > 0:
		label.text = "%s" % int(area_time.time_left)
		if area_time.time_left < 1:
			# add audio
			label.text = "Go!"

func toggle_guide(_show: bool):
	pos_1.visible = _show
	pos_2.visible = _show
	pos_3.visible = _show
	pos_4.visible = _show
	border.visible = _show
	if _show:
		pos_1.play("default")
		pos_2.play("default")
		pos_3.play("default")
		pos_4.play("default")

func is_divisible_by_five(_num):
	if _num % 5 == 0:
		return true
	else:
		return false

func random_speed():
	randomize()
	var _random_float = randf_range(0, 0.05)
	return _random_float
	
func spawn_garbage():
	randomize()
	var random_float = randf()
	var _garbage
	if random_float < 0.20:
		_garbage = garbage1.instantiate()
	elif random_float < 0.40:
		_garbage = garbage2.instantiate()
	elif random_float < 0.60:
		_garbage = garbage3.instantiate()
	elif random_float < 0.80:
		_garbage = garbage4.instantiate()
	elif random_float < 1.00:
		_garbage = garbage5.instantiate()
	_garbage.position = chance_position()
	_garbage.speed += random_speed()
	garbage_counter += 1
	get_tree().get_first_node_in_group("QuestItems").add_child(_garbage)

func chance_position():
	var _pos : Vector2
	randomize()
	var random_float = randf()
	if random_float < 0.25:
		_pos = pos_1.global_position
	elif random_float < 0.50:
		_pos = pos_2.global_position
	elif random_float < 0.75:
		_pos = pos_3.global_position
	elif random_float < 1.00:
		_pos = pos_4.global_position
	return _pos

func check_score(_points: int, _total_spawned: int):
	_points = basket.points
	_total_spawned = garbage_counter
	var _score : float = float(_points)/float(_total_spawned)
	if _score >= 0.75:
		return true
	else:
		return false

func on_quest_failed(_num: int):
	garbage_counter = 0
	basket.points = 0
	started = false

func _on_quest_area_body_entered(body):
	if body.is_in_group("Player") and not started:
		area_time.start()
		toggle_guide(true)
		in_range = true

func _on_quest_area_body_exited(body):
	if body.is_in_group("Player") and not started:
		border.show()
		area_time.stop()
		in_range = false

func _on_time_inside_area_timeout():
	toggle_guide(false)
	timeout = true
	quest_time.start()
	started = true
	
func _on_quest_time_timeout():
	if check_score(basket.points, garbage_counter):
		quest_manager.done.emit(1)
		basket.visible = false
	else:
		quest_manager.failed.emit(1)
	queue_free()

func _on_garbage_detector_body_entered(body):
	if body.is_in_group("Garbage"):
		body.queue_free()
