class_name Types
enum Item {CRYSTAL = 1, WOOD, CASTING_CIRCLE, PYLON}

class ResourceStack:
	var type: Item = Item.CRYSTAL
	var qty: int = 0
	
	func _init(t=Item.WOOD, q=1) -> void:
		self.type = t
		self.qty = q
	
	func _to_string() -> String:
		var string = Item.keys()[self.type - 1]
		string = string + ": " + str(self.qty)
		return string
	
	func duplicate():
		return ResourceStack.new(type, qty)
	
	func equals(other: ResourceStack):
		return type == other.type and qty == other.qty
