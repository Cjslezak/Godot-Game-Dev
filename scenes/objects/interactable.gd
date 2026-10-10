@abstract
extends Node2D
class_name Interactable

@export var properties: ObjectProperties

var _mouse_over = false
var in_range = false
var destroying: bool = false
var destruction_timer: Timer
var destruction_source: Variant

@abstract func _interact(event: InputEvent, interact_from: Variant)

signal destroyed()

## Impliment functionality to execute when the object is destroyed.
func destroy():
	pass

func interact(event: InputEvent, interact_from: Variant):
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
