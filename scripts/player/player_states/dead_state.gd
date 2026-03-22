extends PlayerState

func enter(_old_state: Player.State) -> void:
	player.visuals.set_state(Player.State.DEAD)
	player.queue_free()
