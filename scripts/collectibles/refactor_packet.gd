extends Area2D
class_name RefactorPacket

## A collectible that triggers a refactor process for the player.

@export var loc_value: int = 100

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("collectibles")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# Add LOC for score/progression
		var prog = get_tree().get_first_node_in_group("progression_manager")
		if prog and prog.has_method("add_loc"):
			prog.add_loc(loc_value)
			
		# SUPER POWERUP: Instantly trigger processing for the next tier
		# Even if fragments aren't full.
		if body.has_method("start_processing"):
			body.start_processing(self)
			
		queue_free()
