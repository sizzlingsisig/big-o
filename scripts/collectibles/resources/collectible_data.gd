extends Resource
class_name CollectibleData

## Base resource for all collectible types. Defines visual animation and gameplay effect.

@export var animation_name: StringName = "data_packet"
@export var spawn_weight: float = 10.0
@export var sprite_scale: Vector2 = Vector2(0.8, 0.8)
@export var randomize_color: bool = false
@export var float_animation: bool = true
@export var requires_hover: bool = false

## Virtual method to be overridden by specific collectible types.
func apply_effect(_player: Node) -> void:
	pass