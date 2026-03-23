extends CollectibleData
class_name CorruptedGCData

@export var scramble_duration: float = 4.0
@export var ram_dot_amount: float = 5.0

func _init() -> void:
	animation_name = "corrupted_gc"
	spawn_weight = 1.0

func apply_effect(player: Node2D) -> void:
	if player.has_node("MovementComponent"):
		var move_comp = player.get_node("MovementComponent")
		if move_comp.has_method("trigger_input_scramble"):
			move_comp.trigger_input_scramble(scramble_duration)
	if player.has_node("SystemResourcesComponent"):
		var sys_res = player.get_node("SystemResourcesComponent")
		if sys_res.has_method("apply_ram_dot"):
			sys_res.apply_ram_dot(ram_dot_amount, scramble_duration)
			sys_res.apply_ram_dot(ram_dot_amount, scramble_duration)