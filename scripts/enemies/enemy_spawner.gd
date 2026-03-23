extends Node2D
class_name EnemySpawner

signal enemy_spawned(enemy: BaseEnemy)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)

@export_category("Spawning")
@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_margin: float = 100.0
@export var spawn_delay: float = 1.5
@export var spawn_width: float = 1920.0
@export var spawn_height: float = 1080.0
@export var max_active_enemies: int = 30

@export_category("Wave Configuration")
@export var base_wave_size: int = 3
@export var enemies_per_wave_increase: int = 3
@export var wave_cooldown: float = 8.0

const DIRECTIONS: Array[Vector2] = [
	Vector2(0, -1),   # North
	Vector2(1, -1),   # Northeast
	Vector2(1, 0),    # East
	Vector2(1, 1),    # Southeast
	Vector2(0, 1),    # South
	Vector2(-1, 1),   # Southwest
	Vector2(-1, 0),   # West
	Vector2(-1, -1)   # Northwest
]

const DIRECTION_NAMES: Array[String] = [
	"N", "NE", "E", "SE", "S", "SW", "W", "NW"
]

var _current_wave: int = 0
var _enemies_spawned: int = 0
var _enemies_to_spawn: int = 0
var _wave_active: bool = false
var _active_enemies: Array[BaseEnemy] = []
var _player: Node2D
var _spawn_timer: float = 0.0
var _spawn_index: int = 0
var _is_time_frozen: bool = false

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

func _process(delta: float) -> void:
	if _is_time_frozen:
		return
		
	if _wave_active and _enemies_spawned < _enemies_to_spawn:
		_spawn_timer += delta
		if _spawn_timer >= spawn_delay:
			_spawn_timer = 0.0
			_try_spawn_enemy()

func start_wave() -> void:
	if _wave_active:
		return
	
	_current_wave += 1
	_enemies_to_spawn = base_wave_size + (_current_wave - 1) * enemies_per_wave_increase
	_enemies_spawned = 0
	_wave_active = true
	_spawn_index = 0
	print("[WAVE] Starting wave %d with %d enemies" % [_current_wave, _enemies_to_spawn])
	wave_started.emit(_current_wave)

func _get_spawn_position() -> Vector2:
	var origin = Vector2.ZERO
	if _player and is_instance_valid(_player):
		origin = _player.global_position
	
	var direction_index = _spawn_index % DIRECTIONS.size()
	var _direction = DIRECTIONS[direction_index]
	var half_width = spawn_width / 2 + spawn_margin
	var half_height = spawn_height / 2 + spawn_margin
	
	var offset: Vector2
	match direction_index:
		0: # North
			offset = Vector2(randf_range(-half_width, half_width), -half_height)
		1: # Northeast
			offset = Vector2(half_width, -half_height)
		2: # East
			offset = Vector2(half_width, randf_range(-half_height, half_height))
		3: # Southeast
			offset = Vector2(half_width, half_height)
		4: # South
			offset = Vector2(randf_range(-half_width, half_width), half_height)
		5: # Southwest
			offset = Vector2(-half_width, half_height)
		6: # West
			offset = Vector2(-half_width, randf_range(-half_height, half_height))
		7: # Northwest
			offset = Vector2(-half_width, -half_height)
		_:
			offset = Vector2(randf_range(-half_width, half_width), -half_height)
	
	return origin + offset

func _try_spawn_enemy() -> void:
	if enemy_scenes.is_empty():
		return
	
	if _active_enemies.size() >= max_active_enemies:
		return
	
	var scene = enemy_scenes[randi() % enemy_scenes.size()]
	var enemy = scene.instantiate() as BaseEnemy
	
	if not enemy:
		push_error("EnemySpawner: Spawned node is not a BaseEnemy!")
		return
	
	var direction_index = _spawn_index % DIRECTIONS.size()
	var direction_name = DIRECTION_NAMES[direction_index]
	
	enemy.global_position = _get_spawn_position()
	
	var enemy_name = enemy.name if enemy else "Unknown"
	print("[SPAWN] %s #%d from %s at %v" % [enemy_name, _enemies_spawned + 1, direction_name, enemy.global_position])
	
	_spawn_index += 1
	
	if _player:
		enemy.activate(_player)
	
	enemy.died.connect(_on_enemy_died)
	_active_enemies.append(enemy)
	_enemies_spawned += 1
	enemy_spawned.emit(enemy)

func _on_enemy_died(enemy: BaseEnemy) -> void:
	if _active_enemies.has(enemy):
		_active_enemies.erase(enemy)
	
	if _active_enemies.is_empty() and _enemies_spawned >= _enemies_to_spawn:
		_wave_active = false
		wave_completed.emit(_current_wave)

func get_active_enemy_count() -> int:
	return _active_enemies.size()

func get_current_wave() -> int:
	return _current_wave

func reset_spawner() -> void:
	for enemy in _active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	_current_wave = 0
	_enemies_spawned = 0
	_enemies_to_spawn = 0
	_wave_active = false
	_active_enemies.clear()
	_spawn_timer = 0.0
