extends Node
class_name CollectiblePoolManager

const SectorGridScript = preload("res://scripts/globals/sector_grid.gd")

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
var _respawn_timer: Timer
var _warned_pool_exhausted: bool = false

func _ready() -> void:
	add_to_group("collectible_manager")
	_initialize_default_types()
	_initialize_pool()
	_setup_respawn_timer()
	
	if GameEvents:
		GameEvents.sector_changed.connect(_on_sector_changed)

func _setup_respawn_timer() -> void:
	_respawn_timer = Timer.new()
	_respawn_timer.wait_time = respawn_delay
	_respawn_timer.one_shot = false
	_respawn_timer.autostart = true
	_respawn_timer.timeout.connect(_on_respawn_timeout)
	add_child(_respawn_timer)

func _initialize_default_types() -> void:
	if not collectible_types.is_empty():
		return
	
	collectible_types.append(DataPacketData.new())
	collectible_types.append(GarbageCollectorData.new())
	collectible_types.append(L1CacheHitData.new())
	collectible_types.append(CorruptedGCData.new())
	collectible_types.append(HotfixPatchData.new())

func _on_respawn_timeout() -> void:
	_try_respawn_dormant()

func set_player(player: Node2D) -> void:
	_player = player
	if _player:
		# Bootstrap the very first sector immediately
		_on_sector_changed(SectorGridScript.get_sector_at_position(_player.global_position))

func _on_sector_changed(coords: Vector2i) -> void:
	_current_sector = coords
	_update_sectors()

func _update_sectors() -> void:
	var needed_sectors: Array[Vector2i] = SectorGridScript.get_adjacent_sectors(_current_sector, active_sector_radius)
			
	# Unload distant sectors
	var sectors_to_remove: Array[Vector2i] = []
	for s: Vector2i in _active_sectors.keys():
		if not needed_sectors.has(s):
			sectors_to_remove.append(s)
			
	for s: Vector2i in sectors_to_remove:
		_unload_sector(s)
			
	# Spawn new sectors
	for s: Vector2i in needed_sectors:
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
	var seed_val: int = (coords.x * 73856093) ^ (coords.y * 19349663)
	seed(seed_val)
	
	var sector_center: Vector2 = SectorGridScript.get_sector_center(coords)
	var items_to_spawn: int = randi_range(int(items_per_sector * 0.5), items_per_sector)
	var items_array: Array[Node2D] = []
	
	var pattern: SpawnPattern = _pick_random_spawn_pattern(items_to_spawn)
	print("[CHUNK] Populating sector ", coords, " with pattern: ", pattern.name)
	
	for relative_pos: Vector2 in pattern.relative_positions:
		if _available_collectibles.is_empty():
			break
			
		var spawn_pos: Vector2 = sector_center + relative_pos
		var collectible: Node2D = get_collectible()
		if collectible:
			_initialize_collectible(collectible, spawn_pos, _get_random_collectible_data())
			items_array.append(collectible)
			
	_active_sectors[coords] = items_array
	randomize() # Reset RNG to standard time-based seed for the rest of the game

func _pick_random_spawn_pattern(amount: int) -> SpawnPattern:
	# Pure Agar.io style: scatter uniformly across the entire sector
	var half_sector = SectorGridScript.get_half_sector_size()
	return SpawnPattern.create_scatter(amount, half_sector)

func _initialize_pool() -> void:
	for scene: PackedScene in collectible_scenes:
		for _i: int in range(pool_size / max(1, collectible_scenes.size())):
			var collectible: Node2D = scene.instantiate() as Node2D
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
		if not _warned_pool_exhausted:
			push_warning("CollectiblePoolManager: pool exhausted. Increase pool_size or reduce spawned density.")
			_warned_pool_exhausted = true
		return null
	
	var collectible: Node2D = _available_collectibles.pop_back() as Node2D
	if collectible and is_instance_valid(collectible):
		_active_collectibles.append(collectible)
		_warned_pool_exhausted = false
	return collectible

func return_to_pool(collectible: Node2D) -> void:
	if not collectible or not is_instance_valid(collectible):
		return
	
	var idx = _active_collectibles.find(collectible)
	if idx >= 0:
		_active_collectibles.remove_at(idx)
	
	# Try to find and remove from its sector tracker
	for sector: Array[Node2D] in _active_sectors.values():
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

	_initialize_collectible(collectible, pos, data)

func _initialize_collectible(collectible: Node2D, spawn_pos: Vector2, data: CollectibleData) -> void:
	if collectible is BaseCollectible:
		var typed_collectible: BaseCollectible = collectible as BaseCollectible
		if not typed_collectible.collected.is_connected(_on_collectible_collected):
			typed_collectible.collected.connect(_on_collectible_collected)
		typed_collectible.set_data(data)
		typed_collectible.global_position = spawn_pos
		typed_collectible.visible = true
		typed_collectible.monitoring = true
		typed_collectible.monitorable = true
		typed_collectible.set_process(true)
		typed_collectible.set_physics_process(true)
		typed_collectible.activate()

func _get_random_collectible_data() -> CollectibleData:
	if collectible_types.is_empty():
		return null
		
	var total_weight: float = 0.0
	for data: CollectibleData in collectible_types:
		total_weight += data.spawn_weight
	
	var roll: float = randf() * total_weight
	var current_weight: float = 0.0
	
	for data: CollectibleData in collectible_types:
		current_weight += data.spawn_weight
		if roll <= current_weight:
			return data

	var fallback: CollectibleData = collectible_types[0]
	push_warning("CollectiblePoolManager: weighted collectible roll failed, using fallback type.")
	return fallback

func _try_respawn_dormant() -> void:
	if _available_collectibles.is_empty() or not _player:
		return
	
	# Slowly repopulate sectors near the player
	if _active_sectors.has(_current_sector):
		if _active_sectors[_current_sector].size() < items_per_sector / 2.0:
			var spawn_pos: Vector2 = _player.global_position + Vector2(randf_range(-500.0, 500.0), randf_range(-500.0, 500.0))
			
			var collectible: Node2D = get_collectible()
			if collectible:
				_initialize_collectible(collectible, spawn_pos, _get_random_collectible_data())
				
				_active_sectors[_current_sector].append(collectible)

func _on_collectible_collected(collectible: BaseCollectible) -> void:
	return_to_pool(collectible)

func get_pool_status() -> Dictionary:
	return {
		"available": _available_collectibles.size(),
		"active": _active_collectibles.size(),
		"total": _available_collectibles.size() + _active_collectibles.size()
	}
