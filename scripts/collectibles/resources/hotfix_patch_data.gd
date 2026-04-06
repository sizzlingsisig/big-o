extends CollectibleData
class_name HotfixPatchData

@export var shield_amount: int = 3

func _init() -> void:
	animation_name = "hotfix_patch"
	spawn_weight = 0.5
	requires_hover = false
	float_animation = true

func apply_effect(player: Node2D) -> void:
	if player.has_method("add_shields"):
		player.add_shields(shield_amount)
	GameEvents.hotfix_patch_collected.emit()