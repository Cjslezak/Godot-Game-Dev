extends Node
class_name CraftHandler

@export var recipes: Array[CraftingRecipe]
@export var input_inventory_handler: NodePath
@export var output_inventory_handler: NodePath
@export var recipe_selection_grid: NodePath

@export_category("Optional Controls")
@export var progress_bar_path: NodePath
@export var start_button_path: NodePath

@onready var input_inventory: InventoryHandler = get_node(input_inventory_handler)
@onready var output_inventory: InventoryHandler = get_node(output_inventory_handler)
@onready var recipe_grid: GridContainer = get_node(recipe_selection_grid)

var progress_bar: CraftProgressBar
var start_button: Button
var selected_recipe: CraftingRecipe
var remaining_time: float:
	get:
		return $Timer.time_left
var in_progress: bool = false
var recipe_slots: Array[InventorySlot]

signal craft_completed(recipe: CraftingRecipe)

func set_recipes():
	for c in recipe_grid.get_children():
		c.free()
		
	for recipe in recipes:
		var slot: InventorySlot = preload("res://scenes/inventory/InventorySlot.tscn").instantiate()
		slot.allow_drag = false
		slot.allow_drop = false
		slot.set_contents(recipe.results.keys()[0], recipe.results.values()[0])
		slot.item_clicked.connect(select_recipe)
		recipe_grid.add_child(slot)
		recipe_slots.append(slot)
	
func _ready():
	if not start_button_path.is_empty():
		start_button = get_node(start_button_path)
		start_button.pressed.connect(start_craft)
	
	if not progress_bar_path.is_empty():
		progress_bar = get_node(progress_bar_path)
		progress_bar.set_timer($Timer)
	
	set_recipes()
	
func select_recipe(slot: InventorySlot):
	selected_recipe = recipes[recipe_slots.find(slot)]
	
	for s in recipe_slots:
		if s == slot:
			s.modulate = Globals.HighlightColor
		else:
			s.modulate = Color(1.0, 1.0, 1.0, 1.0)

func start_craft() -> CraftingRecipe:
	if selected_recipe != null:
		for requirement in selected_recipe.ingredients:
			var qty = selected_recipe.ingredients[requirement]
			if not input_inventory.take_qty(requirement, qty):
				return null
			
		in_progress = true
		
		$Timer.start(selected_recipe.time)
		if progress_bar != null:
			progress_bar.set_process(true)
		return selected_recipe
	return null

func _on_timer_timeout() -> void:
	in_progress = false
	craft_completed.emit(selected_recipe)
	for i in selected_recipe.results:
		output_inventory.add_qty(i, selected_recipe.results[i])
	if progress_bar != null:
		progress_bar.set_process(false)
	
