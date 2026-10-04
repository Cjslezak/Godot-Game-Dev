@abstract
extends Node2D
class_name Destructable

@export var properties: ObjectProperties

var in_range: bool
var destroying: bool = false
var timer: Timer

signal destroyed()

func ready():
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func do_destroy(event: InputEvent, strength: float):
	if event.is_action_pressed("destroy_object"):
		destroying = true
		timer.wait_time = properties.hardness / strength
		timer.start()
	elif event.is_action_released("destroy_object"):
		destroying = false

func _on_timer_timeout() -> void:
	print("Destroy")
