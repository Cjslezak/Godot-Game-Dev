extends AnimatableBody2D

var animation_rate = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_loops()
	tween.tween_property(self, "position", position + Vector2(0, -1), animation_rate)
	tween.tween_property(self, "position", position + Vector2(0, 1), animation_rate)
