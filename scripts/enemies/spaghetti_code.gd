extends BaseEnemy

@export_category("Spaghetti Code Behavior")
@export var tether_length: float = 180.0
@export var tether_pull_force: float = 40.0
@export var max_tether_count: int = 2
@export var tangle_speed: float = 25.0

var _tether_count: int = 0
var _tether_points: Array[Vector2] = []
var _is_tangled: bool = false
var _tangle_target: Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var tether_container: Node2D = $TetherContainer

func _ready() -> void:
	super._ready()
	speed = 40.0

func _process_movement(delta: float) -> void:
	if _is_tangled and _tangle_target:
		_process_tether_physics(delta)
	else:
		_process_normal_movement(delta)
	position += velocity * delta

func _process_normal_movement(delta: float) -> void:
	if _target:
		var direction = (_target.global_position - global_position).normalized()
		velocity = velocity.lerp(direction * speed, delta * 3.0)

func _process_tether_physics(delta: float) -> void:
	var to_target = _tangle_target.global_position - global_position
	var distance = to_target.length()
	
	if distance > tether_length:
		var pull_direction = to_target.normalized()
		var pull_strength = (distance - tether_length) * tether_pull_force * delta
		velocity += pull_direction * pull_strength
	
	if to_target != Vector2.ZERO:
		var target_velocity = to_target.normalized() * tangle_speed
		velocity = velocity.lerp(target_velocity, delta * 2.0)
	
	if sprite and (not sprite.is_playing() or sprite.animation != "tangle"):
		sprite.play("tangle")

func _process_behavior(_delta: float) -> void:
	if not _target or _tether_count >= max_tether_count:
		return
	
	var distance = global_position.distance_to(_target.global_position)
	if distance <= tether_length * 0.8 and not _is_tangled:
		_attempt_tangle(_target)

func _attempt_tangle(target: Node2D) -> void:
	_tangle_target = target
	_is_tangled = true
	_tether_count += 1
	_add_tether_point(global_position)
	
	if sprite:
		sprite.play("tangle")

func _add_tether_point(pos: Vector2) -> void:
	_tether_points.append(pos)

func _draw() -> void:
	if _tether_points.size() > 1:
		for i in range(_tether_points.size() - 1):
			draw_line(_tether_points[i] - global_position, _tether_points[i + 1] - global_position, Color.ORANGE, 3.0)
	
	if _is_tangled and _tangle_target:
		draw_line(Vector2.ZERO, _tangle_target.global_position - global_position, Color.YELLOW, 2.0)

func _on_activated() -> void:
	super._on_activated()
	_is_tangled = false
	_tether_count = 0
	_tether_points.clear()
	_tangle_target = null
	
	if sprite:
		sprite.play("idle")

func _on_deactivated() -> void:
	super._on_deactivated()
	_is_tangled = false
	_tether_count = 0
	_tether_points.clear()
	_tangle_target = null
