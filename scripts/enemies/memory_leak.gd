extends BaseEnemy

@export_category("Memory Leak Behavior")
@export var growth_rate: float = 0.3
@export var max_scale: float = 3.5
@export var growth_interval: float = 2.5
@export var continuous_ram_drain: float = 1.5
@export var drain_interval: float = 1.0
@export var puddle_scene: PackedScene
@export var puddle_interval: float = 3.0

var _current_scale: float = 1.0
var _growth_timer: float = 0.0
var _drain_timer: float = 0.0
var _puddle_timer: float = 0.0
var _base_speed: float = 80.0
var _is_overlapping_player: bool = false
var _initial_direction: Vector2 = Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var leak_area: Area2D = $LeakArea

func _ready() -> void:
	super._ready()
	_base_speed = speed
	
	if leak_area:
		leak_area.body_entered.connect(_on_leak_area_entered)
		leak_area.body_exited.connect(_on_leak_area_exited)

func _process_movement(delta: float) -> void:
	if _initial_direction == Vector2.ZERO and _target:
		_initial_direction = (_target.global_position - global_position).normalized()
	
	if _initial_direction != Vector2.ZERO:
		var speed_modifier = maxf(0.3, 1.0 - (_current_scale - 1.0) * 0.2)
		velocity = _initial_direction * _base_speed * speed_modifier
		position += velocity * delta

func _process_behavior(delta: float) -> void:
	_growth_timer += delta
	_drain_timer += delta
	_puddle_timer += delta
	
	if _growth_timer >= growth_interval and _current_scale < max_scale:
		_growth_timer = 0.0
		_grow()
	
	if _is_overlapping_player and _drain_timer >= drain_interval:
		_drain_timer = 0.0
		apply_status_effect("ram_drain", {
			"amount": continuous_ram_drain
		})
	
	if puddle_scene and _puddle_timer >= puddle_interval:
		_puddle_timer = 0.0
		_spawn_puddle()

func _on_leak_area_entered(body: Node) -> void:
	if body is Player:
		_is_overlapping_player = true
		_drain_timer = 0.0

func _on_leak_area_exited(body: Node) -> void:
	if body is Player:
		_is_overlapping_player = false

func _grow() -> void:
	_current_scale = minf(max_scale, _current_scale + growth_rate * 0.5)
	scale = Vector2.ONE * _current_scale
	_update_collision()

func _spawn_puddle() -> void:
	if not puddle_scene:
		return
	
	var puddle = puddle_scene.instantiate()
	if puddle:
		puddle.global_position = global_position
		get_parent().add_child(puddle)

func _update_collision() -> void:
	if collision_shape and collision_shape.shape:
		collision_shape.shape.radius = 25.0 * _current_scale

func _draw() -> void:
	var visual_radius = 30.0 * _current_scale
	draw_circle(Vector2.ZERO, visual_radius, Color(0.3, 0.1, 0.4, 0.6))
	draw_arc(Vector2.ZERO, visual_radius, 0, TAU, 16, Color(0.6, 0.2, 0.8, 0.8), 2.0)
	
	for i in range(3):
		var offset = Vector2.from_angle(i * TAU / 3 + _growth_timer) * visual_radius * 0.5
		draw_circle(offset, visual_radius * 0.2, Color(0.8, 0.4, 1.0, 0.5))

func _on_activated() -> void:
	super._on_activated()
	_current_scale = 1.0
	_growth_timer = 0.0
	scale = Vector2.ONE
	_initial_direction = Vector2.ZERO
	_update_collision()
	
	if sprite:
		sprite.play("idle")

func _on_deactivated() -> void:
	super._on_deactivated()
	_current_scale = 1.0
	_growth_timer = 0.0
	_drain_timer = 0.0
	_is_overlapping_player = false
	scale = Vector2.ONE
	_update_collision()
