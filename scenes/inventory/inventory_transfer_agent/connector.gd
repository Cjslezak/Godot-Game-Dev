extends Sprite2D

var animate_items: bool = true
var animate_connector: bool = true
var redraw_each_frame: bool = false

var connected_objects: Array[Node2D]
var connector_color: Color = Color(0.765, 0.349, 0.925, 1.0)

func connect_to(object: Node2D):
	if object not in connected_objects:
		connected_objects.append(object)
		queue_redraw()

func _process(delta: float) -> void:
	if redraw_each_frame:
		queue_redraw()

func _draw():
	if animate_connector and len(connected_objects) > 1:
		var points = PackedVector2Array()
		for object in connected_objects:
			points.append(to_local(object.global_position))
		draw_polyline(points, connector_color)
