extends Node
class_name PlayerState

## Base class for all player states.

var player: Player

func enter(_old_state: Player.State) -> void:
	pass

func exit(_new_state: Player.State) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
