extends Node
class_name EnemyHealthComponent

signal health_changed(current: float, maximum: float)
signal health_depleted

@export var max_health: float = 3.0

var current_health: float:
	get: return _current_health

var _current_health: float = 3.0

func _ready() -> void:
	_current_health = max_health

func take_damage(amount: float) -> void:
	if amount <= 0:
		return
	
	_current_health = maxf(0, _current_health - amount)
	health_changed.emit(_current_health, max_health)
	
	if _current_health <= 0:
		health_depleted.emit()

func heal(amount: float) -> void:
	_current_health = minf(max_health, _current_health + amount)
	health_changed.emit(_current_health, max_health)

func get_health_ratio() -> float:
	if max_health <= 0:
		return 0.0
	return _current_health / max_health
