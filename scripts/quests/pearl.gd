extends Area2D

var timer_display: PanelContainer
var quest_manager: Node
@onready var timed_spawn = $TimedSpawn

func _ready():
	quest_manager = get_tree().get_first_node_in_group("QuestManager")
	timer_display = get_tree().get_first_node_in_group("Time")
	timer_display.visible = true

func _process(_delta):
	timer_display.time_content = timed_spawn.time_left

func _on_body_entered(body):
	if body.is_in_group("Player"):
		timer_display.visible = false
		quest_manager.done.emit(2)
		queue_free()

func _on_timed_spawn_timeout():
	# minus heart
	timer_display.visible = false
	quest_manager.failed.emit(2)
	queue_free()
