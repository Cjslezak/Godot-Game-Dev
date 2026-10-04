class_name ItemStack
extends MarginContainer

var stack : Types.ResourceStack
var allow_drag = true

signal just_dropped()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if stack != null:
		$Image.texture = Globals.ItemTextures[stack.type]
		$Qty.text = str(stack.qty)
		tooltip_text = str(Types.Item.keys()[stack.type - 1]).capitalize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _get_drag_data(_at_position: Vector2) -> Variant:
	if allow_drag:
		var drag_data = {"stack": stack, "source": self}
		set_drag_preview(make_drag_preview())
		return drag_data
	else:
		return null
		
func _on_mouse_entered() -> void:
	$Image.self_modulate = Globals.HighlightColor

func _on_mouse_exited() -> void:
	$Image.self_modulate = Color(1, 1, 1, 1)

func item_dropped():
	just_dropped.emit()

func make_drag_preview():
	var img = TextureRect.new()
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.texture = $Image.texture
	img.size = Vector2(50, 50)
	img.stretch_mode = TextureRect.STRETCH_SCALE
	
	return img

func set_stack(to: Types.ResourceStack):
	$Image.texture = Globals.ItemTextures[to.type]
	$Qty.text = str(to.qty)
	tooltip_text = str(Types.Item.keys()[to.type - 1]).capitalize()
	stack = to
