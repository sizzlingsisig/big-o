extends PlayerState

func enter(_old_state: Player.State) -> void:
	player.visuals.set_state(Player.State.IDLE)

func physics_update(delta: float) -> void:
	var mouse_pos: Vector2 = player.get_global_mouse_position()
	player.movement.process_movement(delta, mouse_pos, player.complexity.get_current_complexity())
