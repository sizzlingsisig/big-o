extends CollectibleData
class_name L1CacheHitData

@export var duration: float = 5.0

func _init() -> void:
	animation_name = "l1_cache_hit"
	spawn_weight = 1.0

func apply_effect(player: Node2D) -> void:
	if player.has_node("MovementComponent"):
		var move_comp = player.get_node("MovementComponent")
		if move_comp.has_method("trigger_l1_cache"):
			move_comp.trigger_l1_cache(duration)
			move_comp.trigger_l1_cache(duration)