extends Node2D

signal effect_started
signal effect_ended

@export var radius: float = 50.0
@export var duration: float = 0.5

var _timer: float = 0.0
var _is_active: bool = false

func _process(delta: float) -> void:
	if not _is_active:
		return
	
	_timer -= delta
	
	if _timer <= 0:
		_end_effect()

func trigger() -> void:
	_is_active = true
	_timer = duration
	visible = true
	effect_started.emit()
	modulate.a = 1.0

func _end_effect() -> void:
	_is_active = false
	visible = false
	effect_ended.emit()

func _draw() -> void:
	if _is_active:
		var alpha = _timer / duration
		draw_circle(Vector2.ZERO, radius, Color(1.0, 0.3, 0.3, alpha * 0.5))
		draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color(1.0, 0.0, 0.0, alpha), 3.0)
