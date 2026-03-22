extends Area2D
class_name CodeFragment

## A common collectible that increases optimization progress.

@export var loc_value: int = 25

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("collectibles")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# Add LOC for score/progression
		var prog = get_tree().get_first_node_in_group("progression_manager")
		if prog and prog.has_method("add_loc"):
			prog.add_loc(loc_value)
			
		# Add optimization progress
		if body.complexity:
			body.complexity.add_optimization_fragment(1)
			
		# Minor visual/audio feedback on player could go here
		
		queue_free()
