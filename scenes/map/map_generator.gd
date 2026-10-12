@tool
extends Node

@export_tool_button("Generate") var generate_action = generate

@export_node_path("TileMapLayer") var background_tilemap_path
@export_node_path("TileMapLayer") var interactable_tilemap_path
@export_node_path("Player") var player_path
@export var generate_on_load: bool = true

var bg_tilemap: TileMapLayer
var fg_tilemap: TileMapLayer
var player: Player

func _ready() -> void:
	if generate_on_load:
		generate()
	
func generate():
	bg_tilemap = get_node(background_tilemap_path)
	fg_tilemap = get_node(interactable_tilemap_path)
	player = get_node(player_path)
