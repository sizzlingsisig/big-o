extends Node2D
class_name EnemySpawner

signal enemy_spawned(enemy: BaseEnemy)
signal difficulty_increased(tier: int, time_elapsed: float)

@export_category("Spawning")
@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_distance_min: float = 600.0
@export var spawn_distance_max: float = 1000.0
@export var max_active_enemies: int = 30

@export_category("Difficulty Scaling")
@export var initial_spawn_delay: float = 3.5
@export var min_spawn_delay: float = 1.2
@export var spawn_delay_decrease_rate: float = 0.005
@export var tier_1_duration: float = 30.0
@export var tier_2_duration: float = 90.0

@export_category("Enemy Mixing")
@export var max_consecutive_same_type: int = 2

enum Tier { TIER_1, TIER_2, TIER_3 }

var _active_enemies: Array[BaseEnemy] = []
var _player: Node2D
var _spawn_timer: float = 0.0
var _current_spawn_delay: float = 2.0
var _elapsed_time: float = 0.0
var _is_time_frozen: bool = false
var _is_active: bool = false

var _last_spawned_types: Array[String] = []
var _current_tier: Tier = Tier.TIER_1
var _notified_tier: int = 1

func _ready() -> void:
	add_to_group("enemy_spawner")
	GameEvents.time_frozen_started.connect(_on_time_frozen_started)
	GameEvents.time_frozen_ended.connect(_on_time_frozen_ended)

func _on_time_frozen_started(_duration: float) -> void:
	_is_time_frozen = true

func _on_time_frozen_ended() -> void:
	_is_time_frozen = false

func set_player(player: Node2D) -> void:
	_player = player

func start_spawning() -> void:
	_is_active = true
	_elapsed_time = 0.0
	_current_spawn_delay = initial_spawn_delay
	_current_tier = Tier.TIER_1
	_notified_tier = 1

func stop_spawning() -> void:
	_is_active = false

func _process(delta: float) -> void:
	if _is_time_frozen or not _is_active:
		return
	
	_elapsed_time += delta
	_update_difficulty()
	
	_spawn_timer += delta
	if _spawn_timer >= _current_spawn_delay:
		_spawn_timer = 0.0
		_try_spawn_enemy()

func _update_difficulty() -> void:
	var new_tier = Tier.TIER_1
	
	if _elapsed_time >= tier_2_duration:
		new_tier = Tier.TIER_3
	elif _elapsed_time >= tier_1_duration:
		new_tier = Tier.TIER_2
	
	if new_tier != _current_tier:
		_current_tier = new_tier
		_notified_tier = new_tier + 1
		difficulty_increased.emit(_notified_tier, _elapsed_time)
		print("[DIFFICULTY] Tier %d at %.1fs" % [_notified_tier, _elapsed_time])
	
	_current_spawn_delay = maxf(min_spawn_delay, initial_spawn_delay - _elapsed_time * spawn_delay_decrease_rate)

func _get_filtered_scenes() -> Array[PackedScene]:
	var filtered: Array[PackedScene] = []
	
	for scene in enemy_scenes:
		var enemy_name = scene.resource_name.to_lower()
		
		match _current_tier:
			Tier.TIER_1:
				if "null_pointer" in enemy_name or "memory_leak" in enemy_name:
					filtered.append(scene)
			Tier.TIER_2:
				if "null_pointer" in enemy_name or "memory_leak" in enemy_name or "stack_overflow" in enemy_name or "spaghetti" in enemy_name:
					filtered.append(scene)
			Tier.TIER_3:
				filtered.append(scene)
	
	if filtered.is_empty():
		filtered = enemy_scenes
	
	return filtered

func _select_enemy_scene(available_scenes: Array[PackedScene]) -> PackedScene:
	var candidates: Array[PackedScene] = []
	var last_type = ""
	
	if _last_spawned_types.size() >= max_consecutive_same_type:
		last_type = _last_spawned_types.back()
	
	for scene in available_scenes:
		var enemy_name = scene.resource_name.to_lower()
		
		if last_type != "" and enemy_name.contains(last_type):
			continue
		
		candidates.append(scene)
	
	if candidates.is_empty():
		candidates = available_scenes
	
	return candidates[randi() % candidates.size()]

func _get_spawn_position() -> Vector2:
	var origin = Vector2.ZERO
	if _player and is_instance_valid(_player):
		origin = _player.global_position
	
	var angle = randf() * TAU
	var distance = randf_range(spawn_distance_min, spawn_distance_max)
	var offset = Vector2.from_angle(angle) * distance
	
	return origin + offset

func _get_spawn_position_for_enemy(enemy_name: String) -> Vector2:
	var origin = Vector2.ZERO
	if _player and is_instance_valid(_player):
		origin = _player.global_position
	
	if "stack_overflow" in enemy_name.to_lower():
		var angle = PI / 2 + randf_range(-0.3, 0.3)
		var distance = randf_range(spawn_distance_min, spawn_distance_max)
		return origin + Vector2.from_angle(angle) * distance
	
	if "memory_leak" in enemy_name.to_lower():
		var angle = randf() * TAU
		var distance = randf_range(spawn_distance_min, spawn_distance_max)
		return origin + Vector2.from_angle(angle) * distance
	
	return _get_spawn_position()

func _try_spawn_enemy() -> void:
	var available_scenes = _get_filtered_scenes()
	
	if available_scenes.is_empty():
		return
	
	if _active_enemies.size() >= max_active_enemies:
		return
	
	var scene = _select_enemy_scene(available_scenes)
	var enemy = scene.instantiate() as BaseEnemy
	
	if not enemy:
		push_error("EnemySpawner: Spawned node is not a BaseEnemy!")
		return
	
	var enemy_name = scene.resource_name
	_last_spawned_types.append(enemy_name)
	if _last_spawned_types.size() > max_consecutive_same_type * 2:
		_last_spawned_types.pop_front()
	
	enemy.global_position = _get_spawn_position_for_enemy(enemy_name)
	
	if _player:
		enemy.activate(_player)
	
	enemy.died.connect(_on_enemy_died)
	_active_enemies.append(enemy)
	enemy_spawned.emit(enemy)

func _on_enemy_died(enemy: BaseEnemy) -> void:
	if _active_enemies.has(enemy):
		_active_enemies.erase(enemy)

func get_active_enemy_count() -> int:
	return _active_enemies.size()

func get_elapsed_time() -> float:
	return _elapsed_time

func get_current_tier() -> int:
	return _current_tier + 1

func reset_spawner() -> void:
	for enemy in _active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	_active_enemies.clear()
	_spawn_timer = 0.0
	_elapsed_time = 0.0
	_current_spawn_delay = initial_spawn_delay
	_last_spawned_types.clear()
	_current_tier = Tier.TIER_1
	_is_active = false
