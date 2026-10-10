extends Node
class_name InventoryTransferAgent

## Point to an object with an inventory handler as a child.
@export var source_inventory_path: NodePath
## Point to an object with an inventory handler as a child.
@export var dest_inventory_path: NodePath
@export var on_demand: bool = false
@export var periodic_time_ms: int = 1000

var source_inventory: InventoryHandler
var dest_inventory: InventoryHandler

func _ready():
	$Timer.one_shot = on_demand
	$Timer.wait_time = float(periodic_time_ms) / 1000
	if not on_demand:
		$Timer.start()
	print(dest_inventory_path)
	if not source_inventory_path.is_empty():
		set_source_inventory(source_inventory_path)
	
	if not dest_inventory_path.is_empty():
		set_dest_inventory(dest_inventory_path)

func transfer_item():
	$Timer.start()

## Find the inventory handler for a target nodepath
func find_object_inventory(object_path: NodePath) -> InventoryHandler:
	var object = get_node(object_path)
	for child in object.get_children():
		if child.is_in_group(&"inventoryHandler"):
			return child
	return null

func set_source_inventory(inventory: NodePath):
	source_inventory = find_object_inventory(inventory)

func set_dest_inventory(inventory: NodePath):
	dest_inventory = find_object_inventory(inventory)

## Begin item transfer process. Should be called by timer.
func item_transfer_triggered():
	if source_inventory == null:
		if not source_inventory_path.is_empty():
			source_inventory = find_object_inventory(source_inventory_path)
	if dest_inventory == null:
		if not dest_inventory_path.is_empty():
			dest_inventory = find_object_inventory(dest_inventory_path)
	
	if source_inventory and dest_inventory:
		var taken_item = source_inventory.take_first_item(1)
		if taken_item:
			dest_inventory.add_stack(taken_item)
