extends ProgressBar
class_name CraftProgressBar

var timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	set_process(false)

func set_timer(t: Timer):
	timer = t

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if timer != null:
		max_value = timer.wait_time
		min_value = 0
		value = timer.wait_time - timer.time_left
		
