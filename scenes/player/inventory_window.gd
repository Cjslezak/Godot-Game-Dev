extends PopupPanel


func _input(event: InputEvent) -> void:
	if event.is_action_released("inventory"):
		hide()
		get_window().set_input_as_handled()
