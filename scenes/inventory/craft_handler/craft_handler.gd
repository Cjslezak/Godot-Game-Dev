extends Node
class_name CraftHandler

@export var recipes: Array[CraftingRecipe]
@export_node_path("InventoryHandler") var input_inventory_handler: NodePath
@export_node_path("InventoryHandler") var output_inventory_handler: NodePath
@export_node_path("GridContainer") var recipe_selection_grid: NodePath

@export_category("Optional Controls")
@export_node_path("ProgressBar") var progress_bar_path: NodePath
@export_node_path("BaseButton") var start_button_path: NodePath

@onready var input_inventory: InventoryHandler = get_node(input_inventory_handler)
@onready var output_inventory: InventoryHandler = get_node(output_inventory_handler)
@onready var recipe_grid: GridContainer = get_node(recipe_selection_grid)

var progress_bar: ProgressBar
var start_button: Button
var selected_recipe: CraftingRecipe
var craft_tweener: Tween
var autostart_tweener: Tween
var recipe_slots: Array[InventorySlot]

var in_progress: bool = false
var percent_complete: float = 0.0
var auto_craft: bool = true

signal craft_completed(recipe: CraftingRecipe)
	
func _ready():
	if not start_button_path.is_empty():
		start_button = get_node(start_button_path)
		start_button.pressed.connect(start_craft)
	
	if not progress_bar_path.is_empty():
		progress_bar = get_node(progress_bar_path)
	
	# Check for crafting ingredients every second.
	# Using timer/tween to try and avoid running a ton of checks in _process.
	if auto_craft:
		autostart_tweener = create_tween()
		autostart_tweener.set_loops()
		autostart_tweener.tween_interval(1)
		autostart_tweener.tween_callback(start_craft)
		
	set_recipes()

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

func select_recipe(slot: InventorySlot):
	selected_recipe = recipes[recipe_slots.find(slot)]
	
	for s in recipe_slots:
		if s == slot:
			s.modulate = Globals.HighlightColor
		else:
			s.modulate = Color(1.0, 1.0, 1.0, 1.0)

func start_craft() -> CraftingRecipe:
	if selected_recipe != null and not in_progress:
		for requirement in selected_recipe.ingredients:
			var qty = selected_recipe.ingredients[requirement]
			if not input_inventory.take_qty(requirement, qty):
				return null
			
		in_progress = true
		percent_complete = 0.0

		craft_tweener = create_tween()
		
		craft_tweener.tween_property(self, "percent_complete", 100.0, selected_recipe.time)
		craft_tweener.tween_callback(on_craft_complete)
		
		if progress_bar != null:
			progress_bar.value = 0.0
			var progress_tween = progress_bar.create_tween()
			progress_tween.tween_property(progress_bar, "value", 100.0, selected_recipe.time)
			progress_tween.tween_callback(func (): progress_bar.value = 0.0)
			
		return selected_recipe
	return null

func on_craft_complete() -> void:
	in_progress = false
	craft_completed.emit(selected_recipe)
	for i in selected_recipe.results:
		output_inventory.add_qty(i, selected_recipe.results[i])
	if auto_craft:
		start_craft()
	
