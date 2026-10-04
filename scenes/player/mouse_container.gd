extends PanelContainer

const pointer_offset = Vector2(20, 50)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	$ProgressBar.hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = get_global_mouse_position() + pointer_offset

func _input(event: InputEvent) -> void:
	if visible:
		Input.use_accumulated_input = false
		
		if event is InputEventMouseMotion:
			global_position = event.global_position + pointer_offset
	else:
		Input.use_accumulated_input = true

func hide_progress():
	hide()
	$ProgressBar.hide()

func show_progress(percent: float):
	## Shows the progress bar at the mouse position at the given percentage (0-100).
	$ProgressBar.value = percent
	if percent >= 100:
		hide()
		$ProgressBar.hide()
	else:
		show()
		$ProgressBar.show()
		update_minimum_size()
		notification(NOTIFICATION_VISIBILITY_CHANGED)
