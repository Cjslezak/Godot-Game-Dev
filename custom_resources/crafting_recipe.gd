extends Resource
class_name CraftingRecipe

@export var ingredients: Dictionary[Types.Item, int]
@export var results: Dictionary[Types.Item, int]
## Time to craft in seconds
@export var time: int
