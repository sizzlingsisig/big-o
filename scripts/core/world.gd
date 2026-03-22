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
	# Decoupled connections via Event Bus
	GameEvents.enemy_spawned.connect(_on_enemy_spawned)
	GameEvents.status_effect_applied.connect(_on_status_effect_applied)
	GameEvents.ram_overflow.connect(_on_ram_overflow)
	GameEvents.player_died.connect(_on_player_died)
	
	if player:
			enemy_spawner.set_player(player)
			enemy_spawner.enemy_spawned.connect(func(e): GameEvents.enemy_spawned.emit(e))
			enemy_spawner.wave_started.connect(func(w): GameEvents.wave_started.emit(w))
			enemy_spawner.wave_completed.connect(func(w): GameEvents.wave_completed.emit(w))
	else:
		push_error("World: Player node not found!")
	
	game_over_screen.visible = false
	
	if auto_start_waves:
		wave_timer.timeout.connect(_on_wave_timer_timeout)
		wave_timer.wait_time = initial_wave_delay
		wave_timer.start()

func _on_enemy_spawned(enemy: Node2D) -> void:
	if enemy.get_parent() == null:
		enemies_container.add_child(enemy)
	
	if enemy is BaseEnemy:
		enemy.died.connect(_on_enemy_died)

func _on_status_effect_applied(type: String, data: Dictionary) -> void:
	match type:
		"disruption":
			if player:
				player.set_control_disrupted(true, data.get("duration", 2.0))
			if control_disruptor:
				control_disruptor.disrupt(data.get("duration", 2.0))
		"ram_drain":
			if player:
				player.add_ram(data.get("amount", 1.0))
		"gravity_pull":
			if player:
				player.apply_external_force(data.get("direction", Vector2.ZERO) * data.get("strength", 0.0))

func _on_enemy_died(_enemy: BaseEnemy) -> void:
	pass

func _on_wave_completed(wave_number: int) -> void:
	_wave_in_progress = false
	print("Wave %d completed!" % wave_number)

func _on_wave_timer_timeout() -> void:
	start_wave()

func start_wave() -> void:
	if _wave_in_progress:
		return
	enemy_spawner.start_wave()
	_wave_in_progress = true

func _on_player_thread_forked(thread: SubThread) -> void:
	projectiles_container.add_child(thread)

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

func _on_ram_overflow() -> void:
	if player:
		player.trigger_dead()

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
