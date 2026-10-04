@abstract
extends Node2D
class_name Interactable

@export var properties: ObjectProperties

var _mouse_over = false
var in_range = false
var destroying: bool = false
var destruction_timer: Timer

@abstract func _interact(event: InputEvent, interact_from: Variant)

signal destroyed()

func interact(event: InputEvent, interact_from: Variant):
	if event.is_action("destroy_object"):
		if is_in_group(&"destructable"):
			do_destroy(event, 1)
	
	_interact(event, interact_from)

func _enter_tree() -> void:
	add_to_group("interactable", true)

	for child in get_children():
		if child.has_signal("mouse_entered") and child.has_signal("mouse_exited"):
			child.connect("mouse_entered", _on_mouse_entered)
			child.connect("mouse_exited", _on_mouse_exit)
	
	destruction_timer = Timer.new()
	destruction_timer.one_shot = true
	destruction_timer.timeout.connect(_on_timer_timeout)
	add_child(destruction_timer)
	
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

func do_destroy(event: InputEvent, strength: float):
	if event.is_action_pressed("destroy_object"):
		destroying = true
		destruction_timer.wait_time = properties.hardness / strength
		destruction_timer.start()
	elif event.is_action_released("destroy_object"):
		destroying = false
		destruction_timer.stop()

func _on_timer_timeout() -> void:
	print("Destroy")
