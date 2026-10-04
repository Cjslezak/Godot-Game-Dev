extends Camera2D

var zoom_rate = 0

### Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
func _input(input: InputEvent):
	var zoom_vel = Vector2.ZERO
	
	if input.is_action_pressed("zoom_in"):
		zoom_vel += Vector2(1 + zoom_rate, 1+zoom_rate)

	if input.is_action_pressed("zoom_out"):
		zoom_vel += Vector2(1 - zoom_rate, 1 - zoom_rate)
	
	if zoom_vel.length() > 0:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "zoom", zoom * zoom_vel, 0.1)
