extends PlayerState

func enter(_old_state: Player.State) -> void:
	player.visuals.set_state(Player.State.FORKING)
	player.fork_started.emit()
	player._is_invulnerable = true

func exit(_new_state: Player.State) -> void:
	player.fork_ended.emit()
	player._is_invulnerable = false
	player.visuals.clear_forking_effect()
