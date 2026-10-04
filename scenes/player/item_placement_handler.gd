extends Control
class_name ItemPlacementHandler

var stack: Types.ResourceStack
var ghost: Sprite2D
var source_inventory: InventoryHandler

func _get_drag_data(_at_position: Vector2) -> Variant:
	if stack.type in Globals.PlacementTextures:
		set_drag_preview(make_drag_preview())
		var drag_data = {"temp": null}
		return drag_data
	return null

func make_drag_preview():
	var img = TextureRect.new()
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.texture = Globals.PlacementTextures[stack.type]
	img.size = Vector2(50, 50)
	img.stretch_mode = TextureRect.STRETCH_SCALE
	
	return img

func create_ghost(ghost_size: Vector2):
	if ghost != null:
		remove_child(ghost)
		ghost.free()
	
	ghost = Sprite2D.new()
	ghost.texture = Globals.PlacementTextures[stack.type]
	ghost.apply_scale(ghost_size / ghost.texture.get_size())
	
	ghost.self_modulate = Globals.GhostColor
	add_child(ghost)

func take_from_inventory() -> bool:
	return source_inventory.take_qty(stack.type, 1)

func move_ghost(pos: Vector2):
	if ghost != null:
		ghost.global_position = pos
