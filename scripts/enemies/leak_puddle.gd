extends Area2D
class_name LeakPuddle

@export var drain_amount: float = 2.0
@export var drain_interval: float = 0.5
@export var lifetime: float = 8.0
@export var max_radius: float = 120.0

var _timer: float = 0.0
var _drain_timer: float = 0.0
var _current_radius: float = 30.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	var tween = create_tween()
	tween.tween_property(self, "_current_radius", max_radius, lifetime)
	tween.tween_callback(queue_free)
	
	_update_collision()

func _process(delta: float) -> void:
	_timer += delta
	_drain_timer += delta
	
	if collision_shape and collision_shape.shape:
		collision_shape.shape.radius = _current_radius
	
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.add_ram(drain_amount)

func _update_collision() -> void:
	if collision_shape and collision_shape.shape:
		collision_shape.shape.radius = _current_radius

func _draw() -> void:
	draw_circle(Vector2.ZERO, _current_radius, Color(0.3, 0.1, 0.4, 0.4))
	draw_arc(Vector2.ZERO, _current_radius, 0, TAU, 24, Color(0.6, 0.2, 0.8, 0.6), 3.0)
	
	for i in range(4):
		var angle = (float(i) / 4) * TAU + _timer * 0.5
		var offset = Vector2.from_angle(angle) * _current_radius * 0.6
		draw_circle(offset, 5.0, Color(0.8, 0.4, 1.0, 0.7))
