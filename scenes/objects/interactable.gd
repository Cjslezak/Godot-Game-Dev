@abstract
class_name Interactable

var _mouse_over = false

@abstract func _interact(event: InputEvent, interact_from: Variant)

func interact(event: InputEvent, interact_from: Variant):
	if event.is_action("destroy_object"):
		do_destroy(event, 1)
	
	_interact(event, interact_from)

func _enter_tree() -> void:
	add_to_group("interactable", true)

	for child in get_children():
		if child.has_signal("mouse_entered") and child.has_signal("mouse_exited"):
			child.connect("mouse_entered", _on_mouse_entered)
			child.connect("mouse_exited", _on_mouse_exit)
	
	#var enabler = VisibleOnScreenEnabler2D.new()
	#add_child(enabler)

func is_mouse_over():
	return _mouse_over

func _on_mouse_entered():
	if in_range:
		modulate = Globals.HighlightColor
		_mouse_over = true
	
func _on_mouse_exit():
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	_mouse_over = false
	
