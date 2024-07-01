extends Area2D
var bounds: Area2D
var timer_display: PanelContainer
var quest_manager: Node
@onready var spawn_time = $SpawnTime

func _ready():
	quest_manager = get_tree().get_first_node_in_group("QuestManager")
	spawn_time.start()
	timer_display = get_tree().get_first_node_in_group("Time")
	timer_display.visible = true
	
func _process(_delta):
	timer_display.time_content = "%s"%spawn_time.time_left

func _on_body_entered(body):
	if body.is_in_group("Player"):
		quest_manager.done.emit(4)
		timer_display.visible = false
		queue_free()

func on_quest_failed():
	timer_display.visible = false
	quest_manager.failed.emit(4)
	queue_free()
	# minus heart
	
func _on_spawn_time_timeout():
	timer_display.visible = false
	on_quest_failed()
