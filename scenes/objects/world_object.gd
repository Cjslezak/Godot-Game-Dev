extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_mouse_entered() -> void:
	$Sprite2D.self_modulate = Color(1.353, 1.353, 1.353, 1.0)
	
func _on_mouse_exited() -> void:
	$Sprite2D.self_modulate = Color(1, 1, 1, 1)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select_object"):
		$Inventory.popup_centered()
