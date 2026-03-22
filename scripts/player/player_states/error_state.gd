extends PlayerState

func enter(_old_state: Player.State) -> void:
	player.visuals.set_state(Player.State.ERROR)
	player.error_started.emit()
	ScreenFX.shake(5.0, 0.3)
	
	if player._error_label:
		player._error_label.modulate.a = 1.0
		var tween = player.create_tween()
		tween.tween_interval(player.error_duration * 0.6)
		tween.tween_property(player._error_label, "modulate:a", 0.0, 0.2)

func exit(_new_state: Player.State) -> void:
	player._error_label.modulate.a = 0.0
	player.error_ended.emit()
	player.visuals.clear_error_effect()
