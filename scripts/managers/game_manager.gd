extends Node
class_name GameStateController

var current_state: String = BigOConstants.STATE_MENU
var world_instance: Node = null
var menu_instance: Node = null
var game_over_instance: Node = null
var victory_instance: Node = null

# Victory stats
var victory_loc: int = 0
var victory_time: float = 0.0

const SCENE_MENU: PackedScene = preload("res://scenes/ui/main_menu.tscn")
const SCENE_WORLD: PackedScene = preload("res://scenes/core/world.tscn")
const SCENE_VICTORY: PackedScene = preload("res://scenes/ui/victory.tscn")

func _ready() -> void:
	GameEvents.game_state_requested.connect(_on_game_state_requested)
	GameEvents.game_state_changed.connect(_on_game_state_changed)
	GameEvents.start_requested.connect(_on_start_requested)
	GameEvents.quit_requested.connect(_on_quit_requested)
	_load_menu()

func _on_start_requested() -> void:
	GameEvents.game_state_requested.emit(BigOConstants.STATE_PLAY)

func _on_quit_requested() -> void:
	get_tree().quit()

func _on_game_state_changed(new_state: String) -> void:
	print("[GameManager] State changed to: ", new_state)

func _load_menu() -> void:
	_cleanup_all_instances()
	get_tree().paused = false
	
	# Start music if not already playing
	var sm = get_node_or_null("/root/SoundManager")
	if sm:
		sm.play_music()
	
	menu_instance = SCENE_MENU.instantiate()
	add_child(menu_instance)
	
	_set_state(BigOConstants.STATE_MENU)
	print("Loaded Menu")

func _load_world() -> void:
	_cleanup_all_instances()
	get_tree().paused = false
	
	# Music continues playing (same track for menu and game)
	var sm = get_node_or_null("/root/SoundManager")
	if sm:
		sm.play_music()  # Ensures music is playing
	
	world_instance = SCENE_WORLD.instantiate()
	add_child(world_instance)
	
	_set_state(BigOConstants.STATE_PLAY)
	print("Loaded World")

func _load_game_over() -> void:
	get_tree().paused = true
	
	if world_instance and is_instance_valid(world_instance):
		pass
	else:
		world_instance = SCENE_WORLD.instantiate()
		add_child(world_instance)
	
	# Play game over sound
	var sm = get_node_or_null("/root/SoundManager")
	if sm:
		sm.play_game_over()
	
	_set_state(BigOConstants.STATE_GAME_OVER)
	print("Loaded Game Over state")

func _load_victory() -> void:
	# Pause the game when showing victory
	get_tree().paused = true
	
	if world_instance and is_instance_valid(world_instance):
		pass
	else:
		world_instance = SCENE_WORLD.instantiate()
		add_child(world_instance)
	
	victory_instance = SCENE_VICTORY.instantiate()
	add_child(victory_instance)
	
	# Pass stats to victory screen
	if victory_instance and victory_instance.has_method("show_victory"):
		victory_instance.show_victory(victory_loc, victory_time)
	
	_set_state(BigOConstants.STATE_VICTORY)
	print("Loaded Victory state")

func set_victory_stats(loc: int, time_survived: float) -> void:
	victory_loc = loc
	victory_time = time_survived

func _cleanup_all_instances() -> void:
	if menu_instance and is_instance_valid(menu_instance):
		menu_instance.queue_free()
		menu_instance = null
	if world_instance and is_instance_valid(world_instance):
		world_instance.queue_free()
		world_instance = null
	if game_over_instance and is_instance_valid(game_over_instance):
		game_over_instance.queue_free()
		game_over_instance = null
	if victory_instance and is_instance_valid(victory_instance):
		victory_instance.queue_free()
		victory_instance = null

func _set_state(new_state: String) -> void:
	current_state = new_state
	GameEvents.game_state_changed.emit(current_state)

func _on_game_state_requested(state: String) -> void:
	match state:
		BigOConstants.STATE_MENU:
			_load_menu()
		BigOConstants.STATE_PLAY:
			_load_world()
		BigOConstants.STATE_GAME_OVER:
			_load_game_over()
		BigOConstants.STATE_VICTORY:
			_load_victory()
		_:
			push_error("Unknown game state requested: %s" % state)
