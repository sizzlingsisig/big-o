extends CollectibleData
class_name L1CacheHitData

@export var duration: float = 5.0

func _init() -> void:
	animation_name = "l1_cache_hit"
	spawn_weight = 1.0
	requires_hover = false
	float_animation = true

func apply_effect(player: Node) -> void:
	if not player is Player:
		return

	var typed_player: Player = player as Player
	if typed_player.movement:
		typed_player.movement.trigger_l1_cache(duration)