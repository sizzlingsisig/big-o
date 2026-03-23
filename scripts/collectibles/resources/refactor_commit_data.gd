extends CollectibleData
class_name RefactorCommitData

@export var fragment_amount: float = 10.0

func _init() -> void:
	animation_name = "refactor_commit"
	spawn_weight = 0.2
	requires_hover = false
	float_animation = true

func apply_effect(player: Node2D) -> void:
	if player.complexity:
		player.complexity.add_optimization_fragment(fragment_amount)