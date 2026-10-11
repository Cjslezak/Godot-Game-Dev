extends Sprite2D

var animate_items: bool = true
var animate_connector: bool = true
var redraw_each_frame: bool = false

var connected_objects: Array[Node2D] = [null, null, null]
var connector_color: Color = Color(0.765, 0.349, 0.925, 1.0)
var connector_range: int = 5

func connect_to(object: Node2D, index: int):
	if object not in connected_objects:
		connected_objects[index] = object
		queue_redraw()

func _process(_delta: float) -> void:
	if redraw_each_frame:
		queue_redraw()

func _draw():
	var count = 0
	for obj in connected_objects:
		if obj:
			count += 1
			
	if animate_connector and count > 1:
		if connected_objects[0] and connected_objects[1]:
			if is_in_range(connected_objects[0], connected_objects[1]):
				draw_line(
					to_local(connected_objects[0].global_position),
					to_local(connected_objects[1].global_position), 
					connector_color)
		if connected_objects[1] and connected_objects[2]:
			if is_in_range(connected_objects[1], connected_objects[2]):
				draw_line(
					to_local(connected_objects[1].global_position),
					to_local(connected_objects[2].global_position), 
					connector_color)

func is_all_in_range() -> bool:
	for obj in connected_objects:
		if not obj:
			return false
			
	if is_in_range(connected_objects[0], connected_objects[1]) and is_in_range(connected_objects[1], connected_objects[2]):
		return true
	return false

func is_in_range(object1: Node2D, object2: Node2D) -> bool:
	var dist = object1.global_position - object2.global_position
	dist = Globals.scaled_as_tile(dist).length()
	if dist > connector_range:
		return false
	return true
