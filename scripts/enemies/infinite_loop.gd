extends BaseEnemy

signal player_gravity_pull(global_position: Vector2, strength: float, pull_direction: Vector2)

@export_category("Infinite Loop Behavior")
@export var orbit_center: Vector2 = Vector2.ZERO
@export var orbit_radius: float = 250.0
@export var orbit_speed: float = 0.8
@export var gravity_well_strength: float = 200.0
@export var gravity_well_range: float = 300.0

var _orbit_angle: float = 0.0
var _direction: int = 1
var _current_orbit_center: Vector2
var _players_in_well: Array = []
var _current_pull_strength: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var gravity_well_visual: Node2D = $GravityWellVisual
@onready var gravity_area: Area2D = $GravityArea

func _ready() -> void:
	super._ready()
	_current_orbit_center = orbit_center
	
	if gravity_area:
		gravity_area.body_entered.connect(_on_gravity_area_entered)
		gravity_area.body_exited.connect(_on_gravity_area_exited)

func _process_movement(delta: float) -> void:
	_orbit_angle += orbit_speed * _direction * delta
	var target_pos = _current_orbit_center + Vector2.from_angle(_orbit_angle) * orbit_radius
	velocity = (target_pos - global_position) * 5.0
	position += velocity * delta

func _process_behavior(delta: float) -> void:
	_apply_gravity_pull_to_players(delta)

func _apply_gravity_pull_to_players(_delta: float) -> void:
	if _players_in_well.is_empty():
		_current_pull_strength = 0.0
		return
	
	var to_remove = []
	for player_ref in _players_in_well:
		var player = weakref(player_ref).get_ref()
		if not player or not is_instance_valid(player):
			to_remove.append(player_ref)
			continue
		
		var to_target = player.global_position - global_position
		var target_distance = to_target.length()
		
		if target_distance < gravity_well_range:
			_current_pull_strength = gravity_well_strength * (1.0 - target_distance / gravity_well_range)
			var pull_direction = to_target.normalized()
			player_gravity_pull.emit(global_position, _current_pull_strength, pull_direction)
	
	for p in to_remove:
		_players_in_well.erase(p)

func _on_gravity_area_entered(body: Node) -> void:
	if body is Player and not _players_in_well.has(body):
		_players_in_well.append(body)

func _on_gravity_area_exited(body: Node) -> void:
	if body is Player:
		_players_in_well.erase(body)

func reverse_direction() -> void:
	_direction *= -1

func _draw() -> void:
	draw_arc(Vector2.ZERO, orbit_radius, 0, TAU, 32, Color(0.2, 0.5, 1.0, 0.3), 2.0)
	
	var well_alpha = 0.2 + (_current_pull_strength / gravity_well_strength) * 0.3
	draw_circle(Vector2.ZERO, gravity_well_range * 0.5, Color(0.3, 0.3, 1.0, well_alpha))
	
	var arrow_dir = Vector2.from_angle(_orbit_angle + PI * 0.5 * _direction)
	draw_line(Vector2.ZERO, arrow_dir * 20, Color.CYAN, 3.0)

func _on_activated() -> void:
	super._on_activated()
	_current_orbit_center = orbit_center
	_orbit_angle = global_position.angle_to_point(orbit_center)
	_direction = 1 if randf() > 0.5 else -1
	_players_in_well.clear()
	
	if sprite:
		sprite.play("orbit")

func _on_deactivated() -> void:
	super._on_deactivated()
	_current_orbit_center = orbit_center
	_orbit_angle = 0.0
	_players_in_well.clear()
	_current_pull_strength = 0.0
