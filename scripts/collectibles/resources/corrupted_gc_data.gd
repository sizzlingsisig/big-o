extends CollectibleData
class_name CorruptedGCData

@export var ram_damage: float = 20.0

func _init() -> void:
	animation_name = "corrupted_gc"
	spawn_weight = 1.0
	requires_hover = false
	float_animation = true

func apply_effect(player: Node2D) -> void:
	if player.has_node("SystemResourcesComponent"):
		var sys_res = player.get_node("SystemResourcesComponent")
		if sys_res.has_method("add_ram"):
			sys_res.add_ram(ram_damage)