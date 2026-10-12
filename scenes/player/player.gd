extends Character
class_name Player

@export var speed = 400
@export var zoom_rate = 0.5

var screen_size
var has_other_inventory = false
var inventory_currently_open = false
var other_inventory_handler: InventoryPassHandler = null
var progress_source: Node = null
var placement_handler_pointer: ItemPlacementHandler = null

signal start_placing_object(handler: ItemPlacementHandler)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	$Camera2D.zoom_rate = zoom_rate
	Globals.inventory_popup_requested.connect(open_object_inventory)
	Globals.inventory_hide_requested.connect($InventoryWindow.hide)

func _process(_delta: float) -> void:
	if is_destroying_anything:
		var percent = (destruction_timer.wait_time - destruction_timer.time_left) / destruction_timer.wait_time * 100
		$UI_Layer/MouseContainer.show_progress(percent)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var _velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if _velocity.length() > 0:
		_velocity = _velocity.normalized() * speed
	var collision = move_and_collide(_velocity * delta, true)
	if collision:
		_velocity = _velocity.slide(collision.get_normal())
	move_and_collide(_velocity * delta)

func _unhandled_input(input: InputEvent):
	if input.is_action_released("inventory"):
		open_inventory()
		get_window().set_input_as_handled()
	var event_handled = false

	var hotbar_button = Globals.current_hotbar_action(input)
	if hotbar_button != null:
		event_handled = press_hotbar(hotbar_button)

	if event_handled:
		get_window().set_input_as_handled()

func open_inventory():
	$InventoryWindow.popup_centered()
	$InventoryWindow.reset_size()
	$UI_Layer/MouseContainer.supressed = true

func open_object_inventory(handler: InventoryPassHandler):
	%InventorySeperator.show()
	if not handler.stack_transfer_request.is_connected($Inventory.add_stack):
		handler.stack_transfer_request.connect($Inventory.add_stack)

	if not handler.stack_transfer_succeed.is_connected(on_transfer_success):
		handler.stack_transfer_succeed.connect(on_transfer_success)

	handler.pass_to(%InventoryLayout)
	open_inventory()
	other_inventory_handler = handler
	has_other_inventory = true

func press_hotbar(button: int):
	if button == 0:
		button = 10
	button -= 1
	var i = $HotbarInventory.get_slot_item(button)
	if i != null:
		select_item_stack(i)
		return true
	return false

func select_item_stack(stack: ItemStackResource):
	if placement_handler_pointer:
		if get_viewport().gui_is_dragging():
			get_viewport().gui_cancel_drag()
		placement_handler_pointer.queue_free()
		
	placement_handler_pointer = load("res://scenes/player/item_placement_handler.tscn").instantiate()
	placement_handler_pointer.stack = stack
	placement_handler_pointer.source_inventory = $Inventory
	add_child(placement_handler_pointer)
	placement_handler_pointer.accessibility_drag()
	start_placing_object.emit(placement_handler_pointer)

func _on_interact_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	var interacted = []
	var tile_interaction = false
	for interact_with in $InteractArea.get_overlapping_bodies():
		if interact_with.is_class("TileMapLayer") and interact_with.is_in_group("interactable"):
			tile_interaction = true
			interact_with.interact(event, self)
			mouse_over_tile(interact_with)
			if interact_with.is_in_group("destructable") and Input.is_action_pressed(&"destroy_object") and not is_destroying_tile:
				start_tile_destruction(interact_with)
		elif interact_with.owner.is_in_group("interactable") and interact_with.owner not in interacted:
			if interact_with.owner.is_mouse_over():
				interact_with.owner.interact(event, self)
				interacted.append(interact_with.owner)
	for interact_with in $InteractArea.get_overlapping_areas():
		if interact_with.owner.is_in_group("interactable") and interact_with.owner not in interacted:
			if interact_with.owner.is_mouse_over():
				interact_with.owner.interact(event, self)
				interacted.append(interact_with.owner)
	
	for object in interacted:
		if object.is_mouse_over():
			mouse_over_object(object)
	
	if Input.is_action_pressed(&"destroy_object"):
		if not is_destroying_object:
			for object in interacted:
				start_destruction(object)
	elif event.is_action_released(&"destroy_object"):
		stop_destruction()
	
	if len(interacted) == 0 and not tile_interaction:
		stop_destruction()
		$UI_Layer/MouseContainer.hide_item_texture()

func on_gather_resource(kind: Types.Item, qty: int=1):
	$Inventory.add_item(kind, qty)

func _on_inventory_contents_changed() -> void:
	$HotbarInventory.set_contents($Inventory.contents)

func _on_inventory_window_popup_hide() -> void:
	if has_other_inventory:
		other_inventory_handler.stack_transfer_request.disconnect($Inventory.add_stack)
		other_inventory_handler.stack_transfer_succeed.disconnect(on_transfer_success)
		other_inventory_handler.return_owner()
		has_other_inventory = false
		other_inventory_handler = null
	$UI_Layer/MouseContainer.supressed = false

func _on_inventory_hotbar_pressed(button: int, stack: ItemStack) -> void:
	if stack != null:
		if button == 0:
			button = 10
		button -= 1
		$HotbarInventory.set_strict_slot(button, stack.stack.type)

func _on_inventory_item_clicked(item: ItemStackResource, _source: InventoryHandler) -> void:
	if has_other_inventory:
		other_inventory_handler.transfer_stack_to(item)

func on_transfer_success(stack: ItemStackResource):
	$Inventory.take_qty(stack.type, stack.qty)

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.owner.is_in_group("interactable"):
		body.owner.in_range = true

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.owner != null:  # Required since slot gets triggered on object removal. 
		if body.owner.is_in_group("interactable"):
			body.owner.in_range = false
	else:
		$UI_Layer/MouseContainer.hide_item_texture()

func _on_destroy_abort():
	$UI_Layer/MouseContainer.hide_progress()

func _on_destruction_complete(object: Interactable):
	for drop in object.properties.drops:
		on_gather_resource(drop, object.properties.drops[drop])
	object.destroy()

func _on_tile_destruction_complete(resource: Types.Item, layer: InteractableLayer):
	on_gather_resource(resource)
	mouse_over_tile(layer)

func mouse_over_object(object: Interactable):
	$UI_Layer/MouseContainer.show_item_texture(object.properties.display_type)

func mouse_over_tile(layer: InteractableLayer):
	var tile_pos = layer.local_to_map(layer.get_local_mouse_position())
	var data = layer.get_cell_tile_data(tile_pos)
	if data and data.has_custom_data("Terrain"):
		var item = data.get_custom_data("Terrain") as Types.Item
		var qty = layer.get_qty_at_pos(tile_pos)
		$UI_Layer/MouseContainer.show_item_texture(item, qty)
	else:
		$UI_Layer/MouseContainer.hide_item_texture()
		if is_destroying_tile:
			stop_destruction()
		
