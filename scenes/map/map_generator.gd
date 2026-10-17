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
@export_range(-1.0, 1.0, 0.0001) var test_threshold: float = 0.02
@export var noise_map_image: Image = Image.new():
	get:
		return noise_map_image

@export var threshold_map_image: BitMap = BitMap.new():
	get:
		return threshold_map_image

var bg_tilemap: TileMapLayer
var fg_tilemap: TileMapLayer
var player: Player

var chunk_queue: Array[Vector2i] = []
var loaded_chunks: Array[Vector2i] = []
var noise_map: FastNoiseLite

var process_calls: Array[Callable] = []

func _ready() -> void:
	if generate_on_load:
		#generate()
		pass

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
	bg_tilemap = get_node(background_tilemap_path)
	fg_tilemap = get_node(interactable_tilemap_path)
	bg_tilemap.clear()
	player = get_node(player_path)
	
	noise_map = FastNoiseLite.new()
	noise_map.seed = RandomNumberGenerator.new().randi()
	noise_map.noise_type = FastNoiseLite.TYPE_PERLIN
	
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
	
	threshold_map_image = bitmap_from_mapping(func(x): return x > test_threshold)
	
	loaded_chunks = []
	
	var temp = get_chunks_near_player()
	loaded_chunks.clear()
	if len(temp) > 0:
		for chunk in temp:
			if chunk not in loaded_chunks:
				chunk_queue.append(chunk)
				
	process_calls.append(generation_function)
	
func generation_function():
	var coords = chunk_queue.pop_front()

	if coords != null:
		var tiles1: Array[Vector2i] = []
		var tiles2: Array[Vector2i] = []
		for x in range(chunk_size.x + 1):
			for y in range(chunk_size.y + 1):
				var local_coords: Vector2i = Vector2i(x, y)
				var tile_coords: Vector2i = local_coords + (coords * chunk_size)
				var n = noise_map.get_noise_2dv(tile_coords)
				if n > test_threshold:
					tiles1.append(tile_coords)
				else:
					tiles2.append(tile_coords)
		process_calls.append(bg_tilemap.set_cells_terrain_connect.bind(tiles1, 0, 0, false))
		process_calls.append(bg_tilemap.set_cells_terrain_connect.bind(tiles2, 0, 1, false))
		if len(chunk_queue) > 0:
			process_calls.insert(0, generation_function)
		
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
