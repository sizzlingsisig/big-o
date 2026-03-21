extends Node2D
class_name GameWorld

## The main game world container.
## Responsible for managing entities, projectiles, and game state.

@onready var player: Player = $Player
@onready var projectiles_container: Node2D = $Projectiles

func _ready() -> void:
	if player:
		player.thread_forked.connect(_on_player_thread_forked)
	else:
		push_error("World: Player node not found!")

func _on_player_thread_forked(thread: SubThread) -> void:
	# Add the thread to the dedicated container (or world root)
	# Using a container keeps the scene tree organized.
	projectiles_container.add_child(thread)
