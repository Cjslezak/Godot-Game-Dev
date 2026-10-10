extends TileMapLayer

var highlight_active = false

signal gather_resource(type: Types.Item)

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func reset_highlight():
	for cell in get_used_cells_by_id(-1, Vector2i(-1, -1), 1):
		set_cell(cell, get_cell_source_id(cell), get_cell_atlas_coords(cell), 0)
		

func interact(event: InputEvent, _source):
	if event is InputEventMouseMotion or event is InputEventKey:
		var tile_pos = local_to_map(get_local_mouse_position())
		var data = get_cell_tile_data(tile_pos)
		if data and data.has_custom_data("Terrain"):
			reset_highlight()
			set_cell(tile_pos, get_cell_source_id(tile_pos), Vector2i(0, 0), 1)
			highlight_active = true
		elif highlight_active:
			highlight_active = false
			reset_highlight()
