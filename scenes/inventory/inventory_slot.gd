extends MarginContainer
class_name InventorySlot

@warning_ignore("unused_signal")
signal item_dropped(item_stack: ItemStackResource, source_stack: ItemStack)

@warning_ignore("unused_signal")
signal item_removed(item_stack: ItemStackResource)

@export var item: ItemStack:
	get:
		if $InventorySlotPanel.get_child_count() > 0:
			return $InventorySlotPanel.get_child(0)
		else:
			return null 
	set(value):
		add_item(value)
@export var allow_drag = true
@export var allow_drop = true

signal hotbar_button(button: int, slot: InventorySlot)
signal item_clicked(slot: InventorySlot)

func _ready():
	$InventorySlotPanel.allow_drops = allow_drop

func _input(event: InputEvent) -> void:
	if $InventorySlotPanel.has_mouse:
		var button = Globals.current_hotbar_action(event)
		if button != null:
			hotbar_button.emit(button, self)
		
		if Input.is_action_just_released("select_object"):
			if item != null:
				item_clicked.emit(self)

## Call specificly when parent inventory needs to be notified that object is leaving.
func remove_item():
	if not is_empty():
		var stack: ItemStack = $InventorySlotPanel.get_child(0)
		item_removed.emit(stack.stack)

func add_item(stack: ItemStack):
	$InventorySlotPanel.add_child(stack)
	stack.allow_drag = allow_drag
	stack.just_dropped.connect(remove_item)

func clear():
	for stack in $InventorySlotPanel.get_children():
		stack.free()

func is_empty():
	var children = $InventorySlotPanel.get_children()
	var child_count = len($InventorySlotPanel.get_children())
	for c in children:
		if c.is_queued_for_deletion():
			child_count -= 1
	return child_count == 0

func set_contents(item_type: Types.Item, qty: int):
	for c in $InventorySlotPanel.get_children():
		c.free()
		
	var stack: ItemStack = preload("res://scenes/inventory/item_stack.tscn").instantiate()
	stack.set_stack(ItemStackResource.new(item_type, qty))
	item = stack
	
func _on_inventory_slot_panel_item_dropped(dropped_item: ItemStackResource, source_obj: ItemStack) -> void:
	item_dropped.emit(dropped_item, source_obj)
