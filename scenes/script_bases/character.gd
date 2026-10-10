@abstract
extends CharacterBody2D
class_name Character

@export var tool_strength = 1.0

var destruction_timer: Timer
var _destroying_object: Interactable
var _destroying_tile_layer: TileMapLayer
var is_destroying_object: bool = false
var is_destroying_tile: bool = false
var is_destroying_anything: bool:
	get:
		return is_destroying_object or is_destroying_tile

## Called when the character begins destroying an object.
func _on_destroying(t: Timer):
	pass

## Called when the character aborts destroying an object.
func _on_destroy_abort():
	pass

## Called when the character finishes destroying an object.
func _on_destruction_complete(object: Interactable):
	pass

func _on_tile_destruction_complete(resource: Types.Item):
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

func start_tile_destruction(layer: TileMapLayer):
	if layer.is_in_group(&"destructable"):
		var tile_pos = layer.local_to_map(layer.get_local_mouse_position())
		var data = layer.get_cell_tile_data(tile_pos)
		if data and data.has_custom_data("Hardness"):
			is_destroying_tile = true
			_destroying_tile_layer = layer
			var hardness = data.get_custom_data("Hardness")
			destruction_timer.wait_time = hardness / tool_strength
			destruction_timer.start()
			_on_destroying(destruction_timer)

func stop_destruction():
	is_destroying_object = false
	is_destroying_tile = false
	destruction_timer.stop()
	_on_destroy_abort()

func on_destruction_timer_timeout():
	if is_destroying_object:
		is_destroying_object = false
		_on_destroy_abort()
		_on_destruction_complete(_destroying_object)
	
	if is_destroying_tile:
		var tile_pos = _destroying_tile_layer.local_to_map(_destroying_tile_layer.get_local_mouse_position())
		var data = _destroying_tile_layer.get_cell_tile_data(tile_pos)
		if data and data.has_custom_data("Terrain"):
			var qty_rem = data.get_custom_data("Drop_Qty")
			var item = data.get_custom_data("Terrain") as Types.Item
			qty_rem = qty_rem - 1
			if qty_rem > 0:
				is_destroying_tile = true
				data.set_custom_data("Drop_Qty", qty_rem)
				destruction_timer.start()
			else:
				_destroying_tile_layer.reset_highlight()
				is_destroying_tile = false
				_on_destroy_abort()
				_destroying_tile_layer.set_cell(tile_pos)
			_on_tile_destruction_complete(item)
