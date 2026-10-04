extends Node2D

const grid_size = Vector2(64, 64)
var placing = false
var placement_handler: ItemPlacementHandler = null

signal structure_placed(item_type: Types.Item)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if placing:
		var viewport = get_viewport() 
		var mouse_pos = get_global_mouse_position()
		mouse_pos = mouse_pos - mouse_pos.posmodv(grid_size) + grid_size/2
		if !viewport.gui_is_dragging():
			placing = false
			if Input.is_action_just_released("select_object"):
				place_structure_at(mouse_pos)
				
			placement_handler.queue_free()
			placement_handler = null
		else:
			placement_handler.move_ghost(mouse_pos)
	
func place_structure_at(p: Vector2):
	if placement_handler.take_from_inventory():
		var structure_object: Node2D = Globals.StructureFiles[placement_handler.stack.type].instantiate()
		structure_object.global_position = p
		add_child(structure_object)
		structure_placed.emit(placement_handler.stack.type)

func _on_player_start_placing_object(handler: ItemPlacementHandler) -> void:
	placing = true
	placement_handler = handler
	placement_handler.create_ghost(grid_size)
