extends Panel

var allow_drops = true

var has_mouse = false

signal item_dropped(dropped_item: Types.ResourceStack, source_object)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	if allow_drops:
		return true
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	#{"stack": Types.ResourceStack, "source": ItemStack}
	var original_stack: ItemStack = data["source"]
	item_dropped.emit(original_stack.stack.duplicate(), original_stack)

func _on_mouse_entered() -> void:
	has_mouse = true
	self_modulate = Globals.HighlightColor

func _on_mouse_exited() -> void:
	has_mouse = false
	self_modulate = Color(1.0, 1.0, 1.0, 1.0)
