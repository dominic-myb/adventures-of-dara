class_name Pawikan extends NPC

@onready var quest_manager = $"../../QuestManager"
@onready var arrow_guide = $ArrowGuide

func _ready():
	arrow_guide.visible = false
	quest_manager.unlocked.connect(enable_arrow_guide)
	quest_manager.accepted.connect(disable_arrow_guide)
	quest_manager.failed.connect(enable_arrow_guide)
	anim = $AnimatedSprite2D
	anim.play("default")

func enable_arrow_guide(_num: int):
	if _num == 1:
		arrow_guide.visible = true
		arrow_guide.play("default")

func disable_arrow_guide(_num: int):
	if _num == 1:
		arrow_guide.visible = false
		#arrow_guide.play("default")
