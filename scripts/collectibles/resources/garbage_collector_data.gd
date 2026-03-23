extends CollectibleData
class_name GarbageCollectorData

@export var fragment_amount: int = 25
@export var ram_damage: float = 10.0

func _init() -> void:
	animation_name = "garbage_collector"
	spawn_weight = 2.0

func apply_effect(player: Node2D) -> void:
	if player.complexity:
		player.complexity.add_optimization_fragment(fragment_amount)
	if player.has_node("SystemResourcesComponent"):
		var sys_res = player.get_node("SystemResourcesComponent")
		if sys_res.has_method("add_ram"):
			sys_res.add_ram(ram_damage)
			sys_res.add_ram(ram_damage)