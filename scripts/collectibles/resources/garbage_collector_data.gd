extends CollectibleData
class_name GarbageCollectorData

@export var fragment_amount: float = 3.0
@export var ram_clear: float = 15.0

func _init() -> void:
	animation_name = "garbage_collector"
	spawn_weight = 2.0
	requires_hover = false
	float_animation = true

func apply_effect(player: Node) -> void:
	if not player is Player:
		return

	var typed_player: Player = player as Player
	if typed_player.complexity:
		typed_player.complexity.add_optimization_fragment(fragment_amount)
	if typed_player.system_resources:
		typed_player.system_resources.clear_ram(ram_clear)