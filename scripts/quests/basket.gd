extends Area2D
var points: int = 0
@onready var right_items = $"../SoundFX/RightItems"
func _on_body_entered(body):
	if body.is_in_group("Garbage"):
		right_items.playing = true
		body.queue_free()
		points += 1
