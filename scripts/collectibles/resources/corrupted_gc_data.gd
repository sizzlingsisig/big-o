extends CollectibleData
class_name CorruptedGCData

@export var ram_damage: float = 20.0

func _init() -> void:
	animation_name = "corrupted_gc"
	spawn_weight = 1.0
	requires_hover = false
	float_animation = true

func apply_effect(player: Node) -> void:
	if not player is Player:
		return

	var typed_player: Player = player as Player
	if typed_player.system_resources:
		typed_player.system_resources.add_ram(ram_damage)