extends Area2D
class_name CodeFragment

## A common collectible that increases optimization progress.

signal collected

@export var loc_value: int = 25

var _is_active: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("collectibles")

func activate() -> void:
	_is_active = true
	collected.connect(_on_collected)

func deactivate() -> void:
	_is_active = false
	if CollectiblePool and is_instance_valid(CollectiblePool):
		CollectiblePool.return_to_pool(self)

func _on_body_entered(body: Node2D) -> void:
	if not _is_active:
		return
	if body is Player:
		var prog = get_tree().get_first_node_in_group("progression_manager")
		if prog and prog.has_method("add_loc"):
			prog.add_loc(loc_value)
			
		if body.complexity:
			body.complexity.add_optimization_fragment(1)
		
		collected.emit()
		_on_collected()

func _on_collected() -> void:
	deactivate()
