extends Node
class_name CollectiblePoolManager

## Manages object pooling for collectibles to prevent GC stutters.
## Recycles collectibles instead of continuously instantiating and freeing them.
## Handles Chunk-Based Spawning in an infinite map.

@export_category("Pool Configuration")
@export var pool_size: int = 500
@export var collectible_scenes: Array[PackedScene] = [
	preload("res://scenes/collectibles/base_collectible.tscn")
]
@export var collectible_types: Array[CollectibleData] = []
@export var respawn_delay: float = 0.5

@export_category("Sector Spawning")
@export var items_per_sector: int = 40
@export var active_sector_radius: int = 1 # 1 means a 3x3 grid around player

var _available_collectibles: Array[Node2D] = []
var _active_collectibles: Array[Node2D] = []
var _active_sectors: Dictionary = {} # Vector2i -> Array[Node2D]
var _current_sector: Vector2i = Vector2i(999999, 999999) # Invalid initial sector

var _player: Node2D
var _respawn_timer: float = 0.0

func _ready() -> void:
	add_to_group("collectible_manager")
	_initialize_default_types()
	_initialize_pool()
	
	if GameEvents:
		GameEvents.sector_changed.connect(_on_sector_changed)

func _initialize_default_types() -> void:
	if not collectible_types.is_empty():
		return
	
	collectible_types.append(DataPacketData.new())
	collectible_types.append(GarbageCollectorData.new())
	collectible_types.append(L1CacheHitData.new())
	collectible_types.append(CorruptedGCData.new())
	collectible_types.append(HotfixPatchData.new())

func _process(delta: float) -> void:
	_respawn_timer += delta
	if _respawn_timer >= respawn_delay:
		_respawn_timer = 0.0
		_try_respawn_dormant()

func set_player(player: Node2D) -> void:
	_player = player
	if _player:
		# Bootstrap the very first sector immediately
		var sector_size = BigOConstants.SECTOR_SIZE
		var pos = _player.global_position
		_on_sector_changed(Vector2i(int(pos.x / sector_size), int(pos.y / sector_size)))

func _on_sector_changed(coords: Vector2i) -> void:
	_current_sector = coords
	_update_sectors()

func _update_sectors() -> void:
	var needed_sectors = []
	for x in range(-active_sector_radius, active_sector_radius + 1):
		for y in range(-active_sector_radius, active_sector_radius + 1):
			needed_sectors.append(_current_sector + Vector2i(x, y))
			
	# Unload distant sectors
	var sectors_to_remove = []
	for s in _active_sectors.keys():
		if not needed_sectors.has(s):
			sectors_to_remove.append(s)
			
	for s in sectors_to_remove:
		_unload_sector(s)
			
	# Spawn new sectors
	for s in needed_sectors:
		if not _active_sectors.has(s):
			_spawn_sector(s)

func _unload_sector(coords: Vector2i) -> void:
	if not _active_sectors.has(coords): return
	
	var items = _active_sectors[coords]
	for item in items:
		if is_instance_valid(item) and _active_collectibles.has(item):
			return_to_pool(item)
	
	_active_sectors.erase(coords)
	print("[CHUNK] Unloaded sector ", coords)

func _spawn_sector(coords: Vector2i) -> void:
	# Use sector coordinates as RNG seed so the chunk always generates the same pattern
	var seed_val = (coords.x * 73856093) ^ (coords.y * 19349663)
	seed(seed_val)
	
	var sector_center = Vector2(coords.x * BigOConstants.SECTOR_SIZE + (BigOConstants.SECTOR_SIZE/2.0), coords.y * BigOConstants.SECTOR_SIZE + (BigOConstants.SECTOR_SIZE/2.0))
	var items_to_spawn = randi_range(int(items_per_sector * 0.5), items_per_sector)
	var items_array: Array[Node2D] = []
	
	var pattern = _pick_random_spawn_pattern(items_to_spawn)
	print("[CHUNK] Populating sector ", coords, " with pattern: ", pattern.name)
	
	for relative_pos in pattern.relative_positions:
		if _available_collectibles.is_empty():
			break
			
		var spawn_pos = sector_center + relative_pos
		var collectible = get_collectible()
		if collectible:
			if collectible.has_method("set_data"):
				collectible.set_data(_get_random_collectible_data())
			
			collectible.global_position = spawn_pos
			collectible.visible = true
			collectible.monitoring = true
			collectible.monitorable = true
			collectible.set_process(true)
			collectible.set_physics_process(true)
			
			if collectible.has_method("activate"):
				collectible.activate()
			
			items_array.append(collectible)
			
	_active_sectors[coords] = items_array
	randomize() # Reset RNG to standard time-based seed for the rest of the game

func _pick_random_spawn_pattern(amount: int) -> SpawnPattern:
	# Pure Agar.io style: scatter uniformly across the entire sector
	var half_sector = BigOConstants.SECTOR_SIZE / 2.0
	return SpawnPattern.create_scatter(amount, half_sector)

func _initialize_pool() -> void:
	for scene in collectible_scenes:
		for i in range(pool_size / max(1, collectible_scenes.size())):
			var collectible = scene.instantiate() as Node2D
			if collectible:
				collectible.set_process(false)
				collectible.set_physics_process(false)
				collectible.visible = false
				collectible.monitoring = false
				collectible.monitorable = false
				add_child(collectible)
				_available_collectibles.append(collectible)

func get_collectible() -> Node2D:
	if _available_collectibles.is_empty():
		return null
	
	var collectible = _available_collectibles.pop_back() as Node2D
	if collectible and is_instance_valid(collectible):
		_active_collectibles.append(collectible)
	return collectible

func return_to_pool(collectible: Node2D) -> void:
	if not collectible or not is_instance_valid(collectible):
		return
	
	var idx = _active_collectibles.find(collectible)
	if idx >= 0:
		_active_collectibles.remove_at(idx)
	
	# Try to find and remove from its sector tracker
	for sector in _active_sectors.values():
		if sector.has(collectible):
			sector.erase(collectible)
			break
	
	collectible.set_process(false)
	collectible.set_physics_process(false)
	collectible.visible = false
	collectible.set_deferred("monitoring", false)
	collectible.set_deferred("monitorable", false)
	
	if not _available_collectibles.has(collectible):
		_available_collectibles.append(collectible)

func spawn_specific_collectible(pos: Vector2, data: CollectibleData) -> void:
	var collectible = get_collectible()
	if not collectible: return
	
	if collectible.has_method("set_data"):
		collectible.set_data(data)
		
	collectible.global_position = pos
	collectible.visible = true
	collectible.monitoring = true
	collectible.monitorable = true
	collectible.set_process(true)
	collectible.set_physics_process(true)
	
	if collectible.has_method("activate"):
		collectible.activate()

func _get_random_collectible_data() -> CollectibleData:
	if collectible_types.is_empty():
		return null
		
	var total_weight = 0.0
	for data in collectible_types:
		total_weight += data.spawn_weight
	
	var rand = randf() * total_weight
	var current_weight = 0.0
	
	for data in collectible_types:
		current_weight += data.spawn_weight
		if rand <= current_weight:
			return data
			
	return collectible_types[0]

func _try_respawn_dormant() -> void:
	if _available_collectibles.is_empty() or not _player:
		return
	
	# Slowly repopulate sectors near the player
	if _active_sectors.has(_current_sector):
		if _active_sectors[_current_sector].size() < items_per_sector / 2.0:
			var spawn_pos = _player.global_position + Vector2(randf_range(-500.0, 500.0), randf_range(-500.0, 500.0))
			
			var collectible = get_collectible()
			if collectible:
				if collectible.has_method("set_data"):
					collectible.set_data(_get_random_collectible_data())
				
				collectible.global_position = spawn_pos
				collectible.visible = true
				collectible.monitoring = true
				collectible.monitorable = true
				collectible.set_process(true)
				collectible.set_physics_process(true)
				
				if collectible.has_method("activate"):
					collectible.activate()
				
				_active_sectors[_current_sector].append(collectible)

func get_pool_status() -> Dictionary:
	return {
		"available": _available_collectibles.size(),
		"active": _active_collectibles.size(),
		"total": _available_collectibles.size() + _active_collectibles.size()
	}
