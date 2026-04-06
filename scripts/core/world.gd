extends Node2D
class_name GameWorld

@export_category("Survival Mode")
@export var auto_start_spawning: bool = true
@export var initial_spawn_delay: float = 3.0

@onready var player: Player = $Player
@onready var projectiles_container: Node2D = $Projectiles
@onready var enemies_container: Node2D = $Enemies
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var control_disruptor: PlayerControlDisruptor = $ControlDisruptor
@onready var game_over_screen: Node = $GameOver
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var progression_manager: Node = null

var _is_spawning_active: bool = false
var _is_game_over: bool = false
# Phase 3: Removed local _is_paused flag - use get_tree().paused as sole source of truth

func _ready() -> void:
	# Decoupled connections via Event Bus
	GameEvents.enemy_spawned.connect(_on_enemy_spawned)
	GameEvents.status_effect_applied.connect(_on_status_effect_applied)
	GameEvents.ram_overflow.connect(_on_ram_overflow)
	GameEvents.player_died.connect(_on_player_died)

	if player:
		enemy_spawner.set_player(player)
		if is_instance_valid(CollectiblePool):
			CollectiblePool.set_player(player)
		enemy_spawner.enemy_spawned.connect(func(e): GameEvents.enemy_spawned.emit(e))
		enemy_spawner.difficulty_increased.connect(_on_difficulty_increased)
		GameEvents.difficulty_increased.connect(_on_difficulty_increased)
		player.thread_forked.connect(_on_player_thread_forked)
		
		# Connect to optimization complete for victory
		if player.complexity:
			player.complexity.optimization_complete.connect(_on_optimization_complete)
	else:
		push_error("World: Player node not found!")
	
	game_over_screen.visible = false
	
	# Get progression manager for victory stats
	progression_manager = get_tree().get_first_node_in_group("progression_manager")
	
	if auto_start_spawning:
		enemy_spawner.start_spawning()
		_is_spawning_active = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # ESC key
		if not _is_game_over:
			toggle_pause()

func toggle_pause() -> void:
	# Phase 3: Use get_tree().paused as single source of truth
	if get_tree().paused:
		pause_menu.hide_pause_menu()
	else:
		pause_menu.show_pause_menu()

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

func _on_difficulty_increased(tier: int, time_elapsed: float) -> void:
	print("Difficulty increased to Tier %d at %.1fs" % [tier, time_elapsed])

func _on_player_thread_forked(thread: SubThread) -> void:
	projectiles_container.add_child(thread)

func get_active_enemy_count() -> int:
	return enemy_spawner.get_active_enemy_count()

func get_time_survived() -> float:
	return enemy_spawner.get_elapsed_time()

func get_current_tier() -> int:
	return enemy_spawner.get_current_tier()

func get_ram_meter() -> RAMMeter:
	if not is_inside_tree() or not get_tree():
		return null
	var ram_meter = get_node_or_null("../HUD/Control/RAMMeter")
	if not ram_meter:
		ram_meter = get_tree().get_first_node_in_group("ram_meter")
	return ram_meter as RAMMeter

func _on_player_died() -> void:
	print("[World] Player died signal received")
	if not _is_game_over:
		_trigger_game_over("PLAYER_TERMINATED")

func _on_ram_overflow() -> void:
	print("[World] RAM overflow - calling trigger_dead")
	if player:
		player.trigger_dead()
	# Also trigger game over flow
	if not _is_game_over:
		_trigger_game_over("RAM_OVERFLOW")

func _trigger_game_over(reason: String) -> void:
	if _is_game_over:
		return
	
	_is_game_over = true
	enemy_spawner.stop_spawning()
	_is_spawning_active = false
	
	GameEvents.game_state_requested.emit(BigOConstants.STATE_GAME_OVER)
	
	var ram_meter = get_ram_meter()
	var current_ram = 100.0
	var time_survived = enemy_spawner.get_elapsed_time()
	
	if ram_meter:
		current_ram = ram_meter.current_ram
	
	if game_over_screen and game_over_screen.has_method("show_game_over"):
		game_over_screen.visible = true
		game_over_screen.show_game_over(current_ram, time_survived, reason)
	else:
		push_error("GameOver screen or method not found!")
		print("game_over_screen: ", game_over_screen)
		print("has method: ", game_over_screen.has_method("show_game_over") if game_over_screen else "N/A")

func restart_game() -> void:
	_is_game_over = false
	# Phase 3: Use tree.paused instead of local flag
	get_tree().paused = false
	game_over_screen.visible = false
	
	var hud = get_node_or_null("HUD")
	if hud:
		hud.visible = true
	
	enemy_spawner.reset_spawner()
	
	var ram_meter = get_ram_meter()
	if ram_meter:
		ram_meter.clear_ram(ram_meter.max_ram)
	
	enemy_spawner.set_player(player)
	control_disruptor.set_player(player)
	
	if player:
		player.thread_forked.connect(_on_player_thread_forked)
	
	if auto_start_spawning:
		enemy_spawner.start_spawning()
		_is_spawning_active = true

func _on_optimization_complete() -> void:
	print("[World] Victory! Player reached O(1) - requesting victory state")
	
	# Get stats for victory screen
	var loc_processed: int = 0
	var time_survived: float = 0.0
	
	if progression_manager and progression_manager.has_method("get_total_loc"):
		loc_processed = progression_manager.get_total_loc()
	if enemy_spawner:
		time_survived = enemy_spawner.get_elapsed_time()
	
	# Store stats for victory to retrieve
	var victory_node = get_tree().get_first_node_in_group("victory_screen")
	if victory_node and victory_node.has_method("show_victory"):
		victory_node.show_victory(loc_processed, time_survived)
	
	GameEvents.game_state_requested.emit(BigOConstants.STATE_VICTORY)
