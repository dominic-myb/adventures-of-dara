extends Area2D

@onready var collider = $CollisionShape2D
@onready var anim = $AnimatedSprite2D
@onready var player = $"../../Player/Player"
@onready var arrow_guide = $ArrowGuide
@onready var quest_manager = $"../../QuestManager"

func _ready():
	arrow_guide.visible = false
	quest_manager.unlocked.connect(on_quest_unlocked)
	quest_manager.failed.connect(on_quest_failed)
	quest_manager.done.connect(on_quest_done)

func _process(_delta):
	on_sprite_orientation()
	
func on_sprite_orientation():
	if player.global_position.x > position.x:
		anim.flip_h = true
	elif player.global_position.x < position.x:
		anim.flip_h = false

func on_quest_unlocked(_num: int):
	if _num == 5:
		arrow_guide.visible = true
		arrow_guide.play("default")
		anim.play("default")

func on_quest_failed(_num: int):
	if _num == 5:
		arrow_guide.visible = true
		arrow_guide.play("default")
		anim.play("default")
		
func on_quest_done(_num: int):
	arrow_guide.visible = false
	anim.play("done")
