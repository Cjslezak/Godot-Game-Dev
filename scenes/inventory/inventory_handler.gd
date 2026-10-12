extends Node
class_name InventoryHandler

@export var grid_container: NodePath
@export var columns: int = 5
@export var inventory_size: int = 10:
	get:
		return inventory_size
	set(value):
		inventory_size = value
		set_slots()
@export var allow_drag = true
@export var allow_drop = true
@export var only_strict_slots = false
@export var initial_contents: Dictionary[Types.Item, int]

const stack_resource = preload("res://scenes/inventory/item_stack.tscn")

var slots: Array[InventorySlot] = []
var contents: Array[ItemStackResource] = []

var strict_slots: Dictionary[Types.Item, int]

var itemstack_objects: Array[ItemStack]
@onready var inventory_grid: GridContainer = get_node(grid_container)

signal contents_changed()
signal hotbar_pressed(button: int, stack: ItemStack)
signal item_clicked(item: ItemStackResource, inventory: InventoryHandler)

func _ready() -> void:
	set_slots()
	for stack in initial_contents:
		var item = ItemStackResource.new(stack, initial_contents[stack])
		contents.append(item)
	contents_updated()
	for slot in slots:
		slot.allow_drag = allow_drag

## Return index of stack of specified type. -1 if not contained. 
func index_of(type: Types.Item):
	var idx = -1
	for i in contents:
		idx += 1
		if i.type == type:
			break
	return idx

## Return reference to contained stack of specified type.
func stack_of(type: Types.Item) -> ItemStackResource:
	for i in contents:
		if i.type == type:
			return i
	return null

## Remove qty items from inventory. Returns false if unsuccessful.
func take_qty(item_type: Types.Item, qty: int) -> bool:
	for i in contents:
		if i.type == item_type and i.qty >= qty:
			i.qty -= qty
			if i.qty <= 0:
				contents.erase(i)
			contents_updated()
			return true
	return false

## Remove stack from inventory. Returns qty of items removed.
func take_stack(item_type: Types.Item) -> int:
	for i in contents:
		if i.type == item_type:
			var qty = i.qty
			contents.erase(i)
			contents_updated()
			return qty
	return 0

func set_strict_slot(slot_idx: int, type: Types.Item):
	if slot_idx in strict_slots.values():
		strict_slots.erase(type)
	strict_slots[type] = slot_idx
	contents_updated()

func get_slot_item(slot_idx: int) -> ItemStackResource:
	if slot_idx in strict_slots.values():
		var type = strict_slots.find_key(slot_idx)
		for stack in contents:
			if stack.type == type:
				return stack
	return null

func set_slots():
	if inventory_grid == null:
		return
		
	inventory_grid.columns = columns
	for slot in slots:
		slot.free()
	
	slots = []
	itemstack_objects = []
	for x in range(0, inventory_size):
		var slot: InventorySlot = preload("res://scenes/inventory/InventorySlot.tscn").instantiate()
		slots.append(slot)
		slot.item_dropped.connect(on_item_drop)
		slot.item_removed.connect(on_item_removed)
		slot.hotbar_button.connect(on_hotbar_button)
		slot.item_clicked.connect(on_item_click)
		inventory_grid.add_child(slot)
	contents_updated()

func on_item_click(slot: InventorySlot):
	item_clicked.emit(slot.item.stack, self)

func on_hotbar_button(button: int, slot: InventorySlot):
	hotbar_pressed.emit(button, slot.item)
	
func set_contents(list: Array[ItemStackResource]):
	if contents != list:
		contents = list.duplicate_deep()
		contents_updated()

func on_item_removed(removed_stack: ItemStackResource):
	var idx = contents.find_custom(func(x: ItemStackResource): return x.equals(removed_stack))
	if idx >= 0:
		contents.remove_at(idx)
		contents_updated()

func on_item_drop(source_stack: ItemStackResource, source_obj: ItemStack):
	if source_obj not in itemstack_objects and allow_drop:
		var stack = source_stack.duplicate()
		contents.append(stack)
		append_stack(stack)
		source_obj.item_dropped()
		contents_updated()

#TODO: impliment method that divides contents by max stack size
func divide_contents():
	consolidate()

## Consolidate the items in contents to unique types
func consolidate():
	var stacks = {}
	for stack in contents:
		if stack.type in stacks:
			stacks[stack.type] += stack.qty
		else:
			stacks[stack.type] = stack.qty
	
	contents.clear()
	for stack in stacks:
		contents.append(ItemStackResource.new(stack, stacks[stack]))
	
func contents_updated():
	for stack in itemstack_objects:
		stack.queue_free()
	itemstack_objects.clear()
	divide_contents()
	
	for stack in contents:
		append_stack(stack)
	contents_changed.emit()
	
func append_stack(stack: ItemStackResource):
	var stack_object = stack_resource.instantiate()
	stack_object.stack = stack.duplicate()
	itemstack_objects.append(stack_object)
	if stack.type not in strict_slots:
		if not only_strict_slots:
			for slot in slots:
				if slot.is_empty() and slots.find(slot) not in strict_slots.values():
					slot.add_item(stack_object)
					return
	else:
		slots[strict_slots[stack.type]].add_item(stack_object)
		return

func add_item(item: Types.Item, qty: int = 1):
	contents.append(ItemStackResource.new(item, qty))
	contents_updated()
	
func add_qty(type: Types.Item, qty: int):
	var contained_stack = stack_of(type)
	if contained_stack == null:
		var new_stack = ItemStackResource.new(type, qty)
		contents.append(new_stack)
	else:
		contained_stack.qty += qty
	contents_updated()
	
func add_stack(stack: ItemStackResource):
	var contained_stack = contents.find(stack)
	if contained_stack == -1:
		contents.append(stack.duplicate())
	else:
		contained_stack.qty += stack.qty
	contents_updated()

func take_first_item(qty: int = -1) -> ItemStackResource:
	var taken: ItemStackResource = null
	if len(contents) > 0:
		if qty == -1:
			taken = contents.pop_front()
		else:
			taken = contents[0].duplicate()
			if qty < taken.qty:
				taken.qty = qty
				contents[0].qty -= qty
			else:
				contents.remove_at(0)
				
	if taken != null:
		contents_updated()
	return taken
	
