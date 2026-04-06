extends CollectibleData
class_name DataPacketData

@export var fragment_amount: float = 2.0
@export var heal_amount: float = 0.25

func _init() -> void:
	animation_name = "data_packet"
	spawn_weight = 95.0
	sprite_scale = Vector2(0.35, 0.35)
	randomize_color = true
	float_animation = false

func apply_effect(player: Node2D) -> void:
	if player.complexity:
		player.complexity.add_optimization_fragment(fragment_amount)
	if player.has_node("SystemResourcesComponent"):
		var sys_res = player.get_node("SystemResourcesComponent")
		if sys_res.has_method("clear_ram"):
			sys_res.clear_ram(heal_amount)
			sys_res.clear_ram(heal_amount)
	GameEvents.data_packet_collected.emit()