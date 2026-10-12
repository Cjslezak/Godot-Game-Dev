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
@export var generation_thread_count: int = 5

@export_group("Generation Settings")
@export_range(-1.0, 1.0, 0.0001) var test_threshold: float = 0.02

var bg_tilemap: TileMapLayer
var fg_tilemap: TileMapLayer
var player: Player
var generation_threads: Array[Thread] = []
var mutex: Mutex
var semaphore: Semaphore
var bg_mutex: Mutex
var chunk_queue: Array[Vector2i] = []
var loaded_chunks: Array[Vector2i] = []
var kill_threads: bool = false
var noise_map: FastNoiseLite

func _ready() -> void:
	if generate_on_load:
		#generate()
		pass
	
func generate():
	bg_tilemap = get_node(background_tilemap_path)
	fg_tilemap = get_node(interactable_tilemap_path)
	bg_tilemap.clear()
	player = get_node(player_path)
	if not mutex:
		mutex = Mutex.new()
	if not bg_mutex:
		bg_mutex = Mutex.new()

	if not semaphore:
		semaphore = Semaphore.new()
	
	if not noise_map:
		noise_map = FastNoiseLite.new()
	noise_map.noise_type = FastNoiseLite.TYPE_PERLIN
	mutex.lock()
	loaded_chunks = []
	mutex.unlock()
	
	while len(generation_threads) < generation_thread_count:
		var thread = Thread.new()
		generation_threads.append(thread)
		thread.start(generation_thread_function)
	
	var temp = get_chunks_near_player()
	if len(temp) > 0:
		mutex.lock()
		for chunk in temp:
			if chunk not in loaded_chunks:
				chunk_queue.append(chunk)
		mutex.unlock()
		semaphore.post(len(chunk_queue))
	
func generation_thread_function():
	while 1:
		semaphore.wait()
		mutex.lock()
		var coords = chunk_queue.pop_front()
		mutex.unlock()

		if coords:
			var tiles1: Array[Vector2i] = []
			var tiles2: Array[Vector2i] = []
			for x in range(chunk_size.x):
				for y in range(chunk_size.y):
					var local_coords: Vector2i = Vector2i(x, y)
					var tile_coords: Vector2i = local_coords + (coords * chunk_size)
					var n = noise_map.get_noise_2dv(coords)
					if n > test_threshold:
						tiles1.append(tile_coords)
					else:
						tiles2.append(tile_coords)
			bg_mutex.lock()
			bg_tilemap.set_cells_terrain_connect(tiles1, 0, 0)
			bg_tilemap.set_cells_terrain_connect(tiles2, 0, 1)
			bg_mutex.unlock()
		if kill_threads:
			return
	
func get_chunks_near_player() -> Array[Vector2i]:
	var player_pos: Vector2i = bg_tilemap.local_to_map(bg_tilemap.to_local(player.global_position))
	player_pos = player_pos / chunk_size
	
	var check_coords: Array[Vector2i] = []
	for x in range(player_pos.x - generate_range, player_pos.x + generate_range + 1):
		for y in range(player_pos.y - generate_range, player_pos.y + generate_range + 1):
			check_coords.append(Vector2i(x, y))
	return check_coords

func _exit_tree() -> void:
	kill_threads = true
	semaphore.post(len(generation_threads))
	for thread in generation_threads:
		thread.wait_to_finish()
