@tool
extends Resource
class_name GenerationLayer

@export_node_path("TileMapLayer") var layer_path: NodePath
@export var terrain_set: int
@export var terrain_index: int
@export_range(-1.0, 1.0, 0.0001) var threshold: float
