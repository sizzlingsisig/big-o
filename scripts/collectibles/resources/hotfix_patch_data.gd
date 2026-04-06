extends CollectibleData
class_name HotfixPatchData

@export var shield_amount: int = 3

func _init() -> void:
	animation_name = "hotfix_patch"
	spawn_weight = 0.5
	requires_hover = false
	float_animation = true

func apply_effect(player: Node) -> void:
	if player is Player:
		(player as Player).add_shields(shield_amount)