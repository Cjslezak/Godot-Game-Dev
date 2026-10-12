extends Node
class_name InventoryPassHandler

@export var stack_transfer_target_path: NodePath
@export var stack_transfer_sources: Array[NodePath]

@onready var original_parent = get_parent()
@onready var container = get_node("MarginContainer")

signal stack_transfer_request(stack: ItemStackResource)
signal stack_transfer_succeed(stack: ItemStackResource)
var transfer_target: InventoryHandler

func _ready():
	container.hide()
	
	if not stack_transfer_target_path.is_empty():
		transfer_target = get_node(stack_transfer_target_path)
	
	for src_path in stack_transfer_sources:
		var inv = get_node(src_path) as InventoryHandler
		inv.item_clicked.connect(on_transfer_request)
	
	for c in get_children():
		if c != container:
			c.reparent(container)

func on_transfer_request(stack: ItemStackResource, inventory: InventoryHandler):
	inventory.take_qty(stack.type, stack.qty)
	stack_transfer_request.emit(stack)

func transfer_stack_to(stack: ItemStackResource):
	if transfer_target != null:
		transfer_target.add_stack(stack)
		stack_transfer_succeed.emit(stack)

func pass_to(other: Node):
	container.show()
	container.reparent(other)

func return_owner():
	container.reparent(original_parent)
	container.hide()
