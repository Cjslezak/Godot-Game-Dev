@tool
extends Node

@export_tool_button("Generate") var generate_action = generate

@export_node_path("TileMapLayer") var background_tilemap_path
@export_node_path("TileMapLayer") var interactable_tilemap_path
@export_node_path("Player") var player_path

@export_group("Chunk Loading")
@export var chunk_size: Vector2i = Vector2i(16, 16)
@export var generate_range: int = 4
@export var generate_on_load: bool = true

@export_group("Generation Settings")
@export var generation_layers: Array[GenerationLayer] = []
@export var noise_map_image: Image = Image.new():
	get:
		return noise_map_image
@export var threshold_map_images: Array[BitMap] = []

var bg_tilemap: TileMapLayer
var fg_tilemap: TileMapLayer
var player: Player
var noise_map: FastNoiseLite

var chunk_queue: Array[Vector2i] = []
var loaded_chunks: Array[Vector2i] = []
var last_updated_pos: Vector2 = Vector2(0, 0)

var process_calls: Array[Callable] = []

func _ready() -> void:
	player = get_node(player_path)
	bg_tilemap = get_node(background_tilemap_path)
	fg_tilemap = get_node(interactable_tilemap_path)
	
	noise_map = FastNoiseLite.new()
	noise_map.seed = RandomNumberGenerator.new().randi()
	noise_map.noise_type = FastNoiseLite.TYPE_PERLIN
	if generate_on_load:
		generate()

## use a single input lambda function to return an image result from the noise map.
func bitmap_from_mapping(threshold: Callable) -> BitMap:
	var data = BitMap.new()
	data.create(
		Vector2i(
			chunk_size.x * generate_range * 2 + chunk_size.x,
			chunk_size.y * generate_range * 2 + chunk_size.y
			)
		)
	
	var offset = Vector2i(chunk_size.x * generate_range, chunk_size.y * generate_range)
	for y in range(-chunk_size.y * generate_range, chunk_size.y * generate_range + chunk_size.y):
		for x in range(-chunk_size.x * generate_range, chunk_size.x * generate_range + chunk_size.x):
			var coord = Vector2i(x, y)
			var n = noise_map.get_noise_2dv(coord)
			
			data.set_bitv(coord + offset, threshold.call(n))
	return data

func generate():
	bg_tilemap.clear()
	
	var data = PackedFloat32Array()
	var max = -999
	var min = 999
	for y in range(-chunk_size.y * generate_range, chunk_size.y * generate_range + chunk_size.y):
		for x in range(-chunk_size.x * generate_range, chunk_size.x * generate_range + chunk_size.x):
			var coord = Vector2i(x, y)
			var n = noise_map.get_noise_2dv(coord)
			data.append(n)
			if n > max:
				max = n
			if n < min:
				min = n
	var bytes = PackedByteArray()
	for i in data:
		bytes.append(roundi(remap(i, min, max, 0, 255)))
		
	noise_map_image = Image.create_from_data(
		chunk_size.x * generate_range * 2 + chunk_size.x,
		chunk_size.y * generate_range * 2 + chunk_size.y,
		false, Image.FORMAT_L8, bytes)
	var imgs: Array[BitMap] = []
	for gen: GenerationLayer in generation_layers:
		imgs.append(bitmap_from_mapping(func(x): return x > gen.threshold))
	threshold_map_images = imgs
	loaded_chunks = []
	
	var temp = get_chunks_near_player()
	loaded_chunks.clear()
	if len(temp) > 0:
		for chunk in temp:
			if chunk not in loaded_chunks:
				chunk_queue.append(chunk)
	
	last_updated_pos = player.global_position
	process_calls.append(generation_function)
	
func generation_function():
	var coords = chunk_queue.pop_front()

	if coords != null:
		var tiles: Array[Array] = []
		
		for gen: GenerationLayer in generation_layers: 
			tiles.append([])
			
		for x in range(chunk_size.x + 1):
			for y in range(chunk_size.y + 1):
				var local_coords: Vector2i = Vector2i(x, y)
				var tile_coords: Vector2i = local_coords + (coords * chunk_size)
				var n = noise_map.get_noise_2dv(tile_coords)
				var layer_idx = -1
				var highest_match = -99.0
				for idx in generation_layers.size():
					var gen: GenerationLayer = generation_layers[idx]
					if n > gen.threshold and gen.threshold > highest_match:
						layer_idx = idx
						highest_match = gen.threshold
				if layer_idx != -1:
					tiles[layer_idx].append(tile_coords)
				
		for index in generation_layers.size():
			var gen: GenerationLayer = generation_layers[index]
			var layer: TileMapLayer = get_node(gen.layer_path)
			process_calls.append(
				layer.set_cells_terrain_connect.bind(
					tiles[index], gen.terrain_set, gen.terrain_index, false))
		loaded_chunks.append(coords)
		if len(chunk_queue) > 0:
			process_calls.append(generation_function)
		
func get_chunks_near_player() -> Array[Vector2i]:
	var player_pos: Vector2i = bg_tilemap.local_to_map(bg_tilemap.to_local(player.global_position))
	player_pos = player_pos / chunk_size
	
	var check_coords: Array[Vector2i] = []
	for x in range(player_pos.x - generate_range, player_pos.x + generate_range + 1):
		for y in range(player_pos.y - generate_range, player_pos.y + generate_range + 1):
			check_coords.append(Vector2i(x, y))
	return check_coords

func _process(delta: float) -> void:
	var c = process_calls.pop_front()
	if c != null:
		c.call()
	
	if not Engine.is_editor_hint():
		if (Globals.scaled_as_tile(player.global_position) - last_updated_pos).length() > chunk_size.x:
			var temp = get_chunks_near_player()
			if len(temp) > 0:
				for chunk in temp:
					if chunk not in loaded_chunks and chunk not in chunk_queue:
						chunk_queue.append(chunk)
				last_updated_pos = Globals.scaled_as_tile(player.global_position)
				print(last_updated_pos)
			if generation_function not in process_calls:
				process_calls.append(generation_function)
