extends Node
class_name GameManager

var current_state: String = "menu"
var world_instance: Node = null
var menu_instance: Node = null

func _ready() -> void:
	GameEvents.game_state_requested.connect(_on_game_state_requested)
	_load_menu()

func _load_menu() -> void:
	if world_instance:
		world_instance.queue_free()
		world_instance = null
	
	if not menu_instance:
		menu_instance = load("res://scenes/ui/main_menu.tscn").instantiate()
		add_child(menu_instance)
	
	current_state = "menu"
	GameEvents.game_state_changed.emit(current_state)
	print("Loaded Menu")

func _load_world() -> void:
	if menu_instance:
		menu_instance.queue_free()
		menu_instance = null
	
	if not world_instance:
		world_instance = load("res://scenes/core/world.tscn").instantiate()
		add_child(world_instance)
	
	current_state = "play"
	GameEvents.game_state_changed.emit(current_state)
	print("Loaded World")

func _on_game_state_requested(state: String) -> void:
	match state:
		"menu":
			_load_menu()
		"play":
			_load_world()
		_:
			push_error("Unknown game state: %s" % state)
