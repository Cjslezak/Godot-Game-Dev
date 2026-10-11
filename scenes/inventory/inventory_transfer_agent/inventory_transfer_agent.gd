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
var connecting_source: bool = false
var connecting_dest: bool = false

signal connection_complete()

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
	$Connector.connector_range = transfer_tile_range
	
	$Connector.connect_to(get_parent(), 1)

func _input(event: InputEvent) -> void:
	if connecting_source or connecting_dest:
		if event.is_action_released("select_object"):
			event = event as InputEventMouseButton
			var pos = $Connector.get_global_mouse_position()
			var collider: RayCast2D = RayCast2D.new()
			add_child(collider)
			collider.set_collide_with_areas(true)
			collider.set_collision_mask(0b11)
			collider.set_hit_from_inside(true)
			collider.set_global_position(pos)
			collider.force_raycast_update()
			
			var object_at: CollisionObject2D = collider.get_collider()
			collider.queue_free()
			
			if object_at and object_at not in get_parent().get_children():
				if connecting_source:
					if object_at is Player:
						set_source_inventory(object_at.get_path())
					else:
						set_source_inventory(object_at.get_parent().get_path())
					get_window().set_input_as_handled()
				elif connecting_dest:
					if object_at is Player:
						set_dest_inventory(object_at.get_path())
					else:
						set_dest_inventory(object_at.get_parent().get_path())
					get_window().set_input_as_handled()
			connecting_source = false
			connecting_dest = false
			connection_complete.emit()

func transfer_item():
	$Timer.start()

## Find the inventory handler for a target nodepath
func find_object_inventory(object_path: NodePath) -> InventoryHandler:
	var object = get_node(object_path)
	for child in object.get_children():
		if child.is_in_group(&"inventoryHandler"):
			return child
	return null

## Takes the path to an object that contains an inventory handler.
func set_source_inventory(inventory: NodePath):
	source_inventory = find_object_inventory(inventory)
	$Connector.connect_to(get_node(inventory), 0)

## Takes the path to an object that contains an inventory handler.
func set_dest_inventory(inventory: NodePath):
	dest_inventory = find_object_inventory(inventory)
	$Connector.connect_to(get_node(inventory), 2)

## Begin item transfer process. Should be called by timer.
func item_transfer_triggered():
	if source_inventory == null:
		if not source_inventory_path.is_empty():
			source_inventory = find_object_inventory(source_inventory_path)
	if dest_inventory == null:
		if not dest_inventory_path.is_empty():
			dest_inventory = find_object_inventory(dest_inventory_path)
			
	if source_inventory and dest_inventory and $Connector.is_all_in_range():
		var taken_item = source_inventory.take_first_item(1)
		if taken_item:
			dest_inventory.add_stack(taken_item)
