extends CollectibleData
class_name CodeFreezeData

@export var freeze_duration: float = 4.0

func _init() -> void:
	animation_name = "code_freeze"
	spawn_weight = 0.3
	requires_hover = false
	float_animation = true

func apply_effect(_player: Node2D) -> void:
	if GameEvents:
		GameEvents.time_frozen_started.emit(freeze_duration)