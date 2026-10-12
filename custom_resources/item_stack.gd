extends Resource
class_name ItemStackResource

@export var type: Types.Item = Types.Item.CRYSTAL
@export var qty: int = 1

var texture: Resource:
	get:
		if type in Globals.ItemTextures:
			return Globals.ItemTextures[type]
		else:
			return null

func _init(item_type = null, stack_qty = null) -> void:
	if item_type:
		type = item_type
	if stack_qty:
		qty = stack_qty
	
func _to_string() -> String:
	var string = Types.Item.keys()[type - 1]
	string = string + ": " + str(qty)
	return string

func equals(other: ItemStackResource):
	return type == other.type and qty == other.qty
