@abstract
extends CharacterBody2D
class_name Character

@export var tool_strength = 1.0

var destruction_timer: Timer
var _destroying_object: Interactable
var is_destroying_object: bool = false

## Called when the character begins destroying an object.
func _on_destroying(t: Timer):
	pass

## Called when the character aborts destroying an object.
func _on_destroy_abort():
	pass

## Called when the character finishes destroying an object.
func _on_destruction_complete(object: Interactable):
	pass

func _enter_tree() -> void:
	destruction_timer = Timer.new()
	destruction_timer.one_shot = true
	destruction_timer.timeout.connect(on_destruction_timer_timeout)
	add_child(destruction_timer)

func start_destruction(object: Interactable):
	if object.is_in_group(&"destructable"):
		is_destroying_object = true
		_destroying_object = object
		destruction_timer.wait_time = object.properties.hardness / tool_strength
		destruction_timer.start()
		_on_destroying(destruction_timer)

func stop_destruction():
	is_destroying_object = false
	destruction_timer.stop()
	_on_destroy_abort()

func on_destruction_timer_timeout():
	is_destroying_object = false
	_on_destruction_complete(_destroying_object)
	
