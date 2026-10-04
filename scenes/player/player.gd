extends CharacterBody2D
class_name Player

@export var speed = 400
@export var zoom_rate = 0.5

var screen_size
var has_other_inventory = false
var inventory_currently_open = false
var other_inventory_handler: InventoryPassHandler = null
var progress_source: Node = null

signal start_placing_object(handler: ItemPlacementHandler)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	$Camera2D.zoom_rate = zoom_rate

func _process(delta: float) -> void:
	if progress_source is Timer:
		var percent = (progress_source.wait_time - progress_source.time_left) / progress_source.wait_time * 100
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
	

func _input(input: InputEvent):
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

func select_item_stack(stack: Types.ResourceStack):
	print(stack)
	var temp: ItemPlacementHandler = load("res://scenes/player/item_placement_handler.tscn").instantiate()
	temp.stack = stack
	temp.source_inventory = $Inventory
	add_child(temp)
	temp.accessibility_drag()
	start_placing_object.emit(temp)
	

func _on_interact_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	var interacted = []
	for interact_with in $InteractArea.get_overlapping_bodies():
		if interact_with.is_class("TileMapLayer") and interact_with.is_in_group("interactable"):
			interact_with.interact(event, self)
		elif interact_with.owner.is_in_group("interactable") and interact_with.owner not in interacted:
			if interact_with.owner.is_mouse_over():
				interact_with.owner.interact(event, self)
				interacted.append(interact_with.owner)
	for interact_with in $InteractArea.get_overlapping_areas():
		if interact_with.owner.is_in_group("interactable") and interact_with.owner not in interacted:
			if interact_with.owner.is_mouse_over():
				interact_with.owner.interact(event, self)
				interacted.append(interact_with.owner)

func on_gather_resource(kind: Types.Item, qty: int = 1):
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

func _on_inventory_hotbar_pressed(button: int, stack: ItemStack) -> void:
	if stack != null:
		if button == 0:
			button = 10
		button -= 1
		$HotbarInventory.set_strict_slot(button, stack.stack.type)

func _on_inventory_item_clicked(item: Types.ResourceStack, _source: InventoryHandler) -> void:
	if has_other_inventory:
		other_inventory_handler.transfer_stack_to(item)

func on_transfer_success(stack: Types.ResourceStack):
	$Inventory.take_qty(stack.type, stack.qty)


func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.owner.is_in_group("interactable"):
		body.owner.in_range = true

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.owner != null: # Required since slot gets triggered on object removal. 
		if body.owner.is_in_group("interactable"):
			body.owner.in_range = false

func start_progress(source: Node):
	progress_source = source

func stop_progress():
	progress_source = null
	$UI_Layer/MouseContainer.hide_progress()
