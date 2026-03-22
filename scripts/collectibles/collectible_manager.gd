extends Node
class_name CollectiblePoolManager

## Manages object pooling for collectibles to prevent GC stutters.
## Recycles collectibles instead of continuously instantiating and freeing them.


@export_category("Pool Configuration")
@export var pool_size: int = 50
@export var collectible_scenes: Array[PackedScene] = []
@export var respawn_delay: float = 3.0
@export var cull_distance: float = 2000.0

@export_category("Spawn Settings")
@export var spawn_margin: float = 200.0
@export var min_spawn_distance: float = 300.0

var _available_collectibles: Array[Node2D] = []
var _active_collectibles: Array[Node2D] = []
var _player: Node2D
var _respawn_timer: float = 0.0

func _ready() -> void:
	add_to_group("collectible_manager")
	_initialize_pool()

func _process(delta: float) -> void:
	_respawn_timer += delta
	if _respawn_timer >= respawn_delay:
		_respawn_timer = 0.0
		_try_respawn_dormant()

func set_player(player: Node2D) -> void:
	_player = player

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
	
	collectible.set_process(false)
	collectible.set_physics_process(false)
	collectible.visible = false
	collectible.monitoring = false
	collectible.monitorable = false
	
	if not _available_collectibles.has(collectible):
		_available_collectibles.append(collectible)

func activate_collectible(pos: Vector2) -> bool:
	var collectible = get_collectible()
	if not collectible:
		return false
	
	collectible.global_position = pos
	collectible.visible = true
	collectible.monitoring = true
	collectible.monitorable = true
	collectible.set_process(true)
	collectible.set_physics_process(true)
	
	if collectible.has_method("activate"):
		collectible.activate()
	
	return true

func _get_spawn_position() -> Vector2:
	if not _player or not is_instance_valid(_player):
		return Vector2.ZERO
	
	var player_pos = _player.global_position
	var spawn_pos = player_pos + Vector2.from_angle(randf() * TAU) * randf_range(min_spawn_distance, min_spawn_distance + spawn_margin)
	
	spawn_pos.x = clampf(spawn_pos.x, player_pos.x - 2000, player_pos.x + 2000)
	spawn_pos.y = clampf(spawn_pos.y, player_pos.y - 1500, player_pos.y + 1500)
	
	return spawn_pos

func _try_respawn_dormant() -> void:
	if _available_collectibles.is_empty():
		return
	
	var spawn_pos = _get_spawn_position()
	activate_collectible(spawn_pos)

func get_pool_status() -> Dictionary:
	return {
		"available": _available_collectibles.size(),
		"active": _active_collectibles.size(),
		"total": _available_collectibles.size() + _active_collectibles.size()
	}
