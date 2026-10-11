extends Node
class_name InventoryTransferAgent

## Point to an object with an inventory handler as a child.
@export var source_inventory_path: NodePath
## Point to an object with an inventory handler as a child.
@export var dest_inventory_path: NodePath
@export var on_demand: bool = false
@export var periodic_time_ms: int = 1000
@export var transfer_tile_range: int = 5

@export_category("Connector")
@export var animate_items: bool = true
@export var animate_connector: bool = true
@export var redraw_each_frame: bool = false
@export var connector_color: Color = Color(0.765, 0.349, 0.925, 1.0)

var source_inventory: InventoryHandler
var dest_inventory: InventoryHandler

func _ready():
	$Timer.one_shot = on_demand
	$Timer.wait_time = float(periodic_time_ms) / 1000
	if not on_demand:
		$Timer.start()
	if not source_inventory_path.is_empty():
		set_source_inventory(source_inventory_path)
	
	if not dest_inventory_path.is_empty():
		set_dest_inventory(dest_inventory_path)
	
	$Connector.animate_items = animate_items
	$Connector.animate_connector = animate_connector
	$Connector.redraw_each_frame = redraw_each_frame
	$Connector.connector_color = connector_color
	
	$Connector.connect_to(get_parent())


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
	$Connector.connect_to(get_node(inventory))

func set_dest_inventory(inventory: NodePath):
	dest_inventory = find_object_inventory(inventory)
	$Connector.connect_to(get_node(inventory))

func is_in_range() -> bool:
	if source_inventory and dest_inventory:
		var source_object: Node2D = source_inventory.get_parent()
		var dest_object: Node2D = dest_inventory.get_parent()
		var dist = source_object.global_position - dest_object.global_position
		dist = Globals.scaled_as_tile(dist).length()
		if dist <= transfer_tile_range:
			return true
	return false

## Begin item transfer process. Should be called by timer.
func item_transfer_triggered():
	if source_inventory == null:
		if not source_inventory_path.is_empty():
			source_inventory = find_object_inventory(source_inventory_path)
	if dest_inventory == null:
		if not dest_inventory_path.is_empty():
			dest_inventory = find_object_inventory(dest_inventory_path)
	
	if source_inventory and dest_inventory and is_in_range():
		var taken_item = source_inventory.take_first_item(1)
		if taken_item:
			dest_inventory.add_stack(taken_item)
