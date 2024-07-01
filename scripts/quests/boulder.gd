extends CharacterBody2D

var max_hp: float = 50.00 # change health
var hp: float

var dalag : Area2D 
var timer_display: PanelContainer
var quest_manager: Node

@onready var anim = $AnimatedSprite2D
@onready var spawn_time = $SpawnTime
@onready var arrow_guide = $ArrowGuide
@onready var health_bar = $CanvasLayer/Control/HealthBar
@onready var collider = $CollisionShape2D

func _ready():
	quest_manager = get_tree().get_first_node_in_group("QuestManager")
	timer_display = get_tree().get_first_node_in_group("Time")
	dalag = get_tree().get_first_node_in_group("Dalag")
	
	anim.connect("animation_finished", _on_finished)
	hp = max_hp
	health_bar._init_health(hp)
	
	timer_display.visible = true
	arrow_guide.play("default")
	anim.play("default")
	
func _process(delta):
	timer_display.time_content = spawn_time.time_left
	velocity.y += 100 * delta
	move_and_slide()

func take_damage(amount: float):
	if hp <= 0:
		return
	hp -= amount
	health_bar.health = hp
	if (hp / max_hp) <= 0.25:
		anim.play("damaged_3")
	elif (hp / max_hp) <= 0.50:
		anim.play("damaged_2")
	elif (hp / max_hp) <= 0.75:
		anim.play("damaged_1")
	if hp <= 0:
		#health_bar.visible = false
		timer_display.visible = false
		anim.play("powder")

func _on_spawn_time_timeout():
	timer_display.visible = false
	quest_manager.failed.emit(0)
	queue_free()

func _on_finished():
	quest_manager.done.emit(0)
	queue_free()
