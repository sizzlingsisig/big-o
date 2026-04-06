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

func apply_effect(player: Node) -> void:
	if not player is Player:
		return

	var typed_player: Player = player as Player
	if typed_player.complexity:
		typed_player.complexity.add_optimization_fragment(fragment_amount)
	if typed_player.system_resources:
		typed_player.system_resources.clear_ram(heal_amount)
		typed_player.system_resources.clear_ram(heal_amount)