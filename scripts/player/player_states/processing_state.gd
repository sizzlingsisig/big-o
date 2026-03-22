extends PlayerState

func enter(_old_state: Player.State) -> void:
	player.visuals.set_state(Player.State.PROCESSING)
	player.visuals.apply_processing_effect()

func physics_update(delta: float) -> void:
	# Still move a bit or just stay still? Original code says _process_idle(delta)
	var mouse_pos: Vector2 = player.get_global_mouse_position()
	player.movement.process_movement(delta, mouse_pos, player.complexity.get_current_complexity())

func exit(_new_state: Player.State) -> void:
	player.visuals.clear_processing_effect()
