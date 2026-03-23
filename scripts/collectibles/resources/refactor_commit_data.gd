extends CollectibleData
class_name RefactorCommitData

@export var fragment_amount: int = 100

func _init() -> void:
	animation_name = "refactor_commit"
	spawn_weight = 0.2

func apply_effect(player: Node2D) -> void:
	if player.complexity:
		player.complexity.add_optimization_fragment(fragment_amount)