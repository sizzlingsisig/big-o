extends Node2D
class_name GameWorld

@export var auto_start_waves: bool = true
@export var initial_wave_delay: float = 3.0
@export var time_between_waves: float = 8.0

@onready var player: Player = $Player
@onready var projectiles_container: Node2D = $Projectiles
@onready var enemies_container: Node2D = $Enemies
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var control_disruptor: PlayerControlDisruptor = $ControlDisruptor
@onready var game_over_screen: Node = $GameOver
@onready var wave_timer: Timer = $WaveTimer

var _wave_in_progress: bool = false
var _is_game_over: bool = false

func _ready() -> void:
	if player:
		player.thread_forked.connect(_on_player_thread_forked)
		enemy_spawner.set_player(player)
		control_disruptor.set_player(player)
		enemy_spawner.enemy_spawned.connect(_on_enemy_spawned)
		enemy_spawner.wave_completed.connect(_on_wave_completed)
		player.tree_exited.connect(_on_player_died)
	else:
		push_error("World: Player node not found!")
	
	var ram_meter = get_ram_meter()
	if ram_meter:
		ram_meter.game_over.connect(_on_ram_game_over)
	
	game_over_screen.visible = false
	
	if auto_start_waves:
		wave_timer.timeout.connect(_on_wave_timer_timeout)
		wave_timer.wait_time = initial_wave_delay
		wave_timer.start()

func _process(_delta: float) -> void:
	if not _wave_in_progress and enemy_spawner.get_active_enemy_count() == 0:
		if enemy_spawner.get_current_wave() > 0:
			_start_next_wave_timer()

func _on_wave_timer_timeout() -> void:
	start_wave()

func _start_next_wave_timer() -> void:
	wave_timer.stop()
	wave_timer.wait_time = time_between_waves
	wave_timer.start()

func start_wave() -> void:
	if _wave_in_progress:
		return
	enemy_spawner.start_wave()
	_wave_in_progress = true

func _on_player_thread_forked(thread: SubThread) -> void:
	projectiles_container.add_child(thread)

func _on_enemy_spawned(enemy: BaseEnemy) -> void:
	enemies_container.add_child(enemy)
	print("[DEBUG] Enemy '%s' spawned at %v" % [enemy.name, enemy.global_position])
	
	if enemy.has_method("disrupted_player"):
		enemy.disrupted_player.connect(_on_heisenberg_disrupted)
	
	if enemy.has_method("leaking_ram"):
		enemy.leaking_ram.connect(_on_memory_leak_drain)
	
	if enemy.has_method("player_gravity_pull"):
		enemy.player_gravity_pull.connect(_on_gravity_pull)
	
	enemy.died.connect(_on_enemy_died)

func _on_heisenberg_disrupted(duration: float) -> void:
	control_disruptor.disrupt(duration)

func _on_memory_leak_drain(amount: float) -> void:
	var ram_meter = get_ram_meter()
	if ram_meter:
		ram_meter.add_ram(amount)

func _on_gravity_pull(_source_pos: Vector2, strength: float, pull_dir: Vector2) -> void:
	if player and player.has_method("apply_external_force"):
		player.apply_external_force(pull_dir * strength)

func _on_enemy_died(_enemy: BaseEnemy) -> void:
	pass

func _on_wave_completed(wave_number: int) -> void:
	_wave_in_progress = false
	print("Wave %d completed!" % wave_number)

func get_active_enemy_count() -> int:
	return enemy_spawner.get_active_enemy_count()

func get_current_wave() -> int:
	return enemy_spawner.get_current_wave()

func get_ram_meter() -> RAMMeter:
	if not is_inside_tree() or not get_tree():
		return null
	var ram_meter = get_node_or_null("../HUD/Control/RAMMeter")
	if not ram_meter:
		ram_meter = get_tree().get_first_node_in_group("ram_meter")
	return ram_meter as RAMMeter

func _on_player_died() -> void:
	if not _is_game_over:
		_trigger_game_over("PLAYER_TERMINATED")

func _on_ram_game_over() -> void:
	_trigger_game_over("HEAP_OVERFLOW")

func _trigger_game_over(reason: String) -> void:
	if _is_game_over:
		return
	
	_is_game_over = true
	wave_timer.stop()
	_wave_in_progress = false
	
	var ram_meter = get_ram_meter()
	var current_ram = 100.0
	var current_wave = enemy_spawner.get_current_wave()
	
	if ram_meter:
		current_ram = ram_meter.current_ram
	
	game_over_screen.show_game_over(current_ram, current_wave, reason)

func restart_game() -> void:
	_is_game_over = false
	game_over_screen.visible = false
	_wave_in_progress = false
	
	enemy_spawner.reset_spawner()
	
	var ram_meter = get_ram_meter()
	if ram_meter:
		ram_meter.clear_ram(ram_meter.max_ram)
	
	enemy_spawner.set_player(player)
	control_disruptor.set_player(player)
	
	if player:
		player.thread_forked.connect(_on_player_thread_forked)
	
	if auto_start_waves:
		wave_timer.wait_time = initial_wave_delay
		wave_timer.start()
