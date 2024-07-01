extends Area2D

@onready var player = $"../Player/Player"
@onready var quest_manager = $"../QuestManager"
func _on_body_entered(body):
	if body.is_in_group("Player"):
		player.visible = false
		quest_manager.failed.emit(Game.PLAYER_QUEST_LEVEL)

