extends CollectibleData
class_name GarbageCollectorData

@export var fragment_amount: float = 3.0
@export var ram_clear: float = 15.0

func _init() -> void:
	animation_name = "garbage_collector"
	spawn_weight = 2.0
	requires_hover = false
	float_animation = true

func apply_effect(player: Node2D) -> void:
	if player.complexity:
		player.complexity.add_optimization_fragment(fragment_amount)
	if player.has_node("SystemResourcesComponent"):
		var sys_res = player.get_node("SystemResourcesComponent")
		if sys_res.has_method("clear_ram"):
			sys_res.clear_ram(ram_clear)