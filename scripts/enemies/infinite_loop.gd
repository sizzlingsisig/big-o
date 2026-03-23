extends BaseEnemy

@export_category("Infinite Loop Behavior")
@export var orbit_radius: float = 150.0
@export var orbit_speed: float = 2.0
@export var approach_speed: float = 60.0
@export var min_orbit_distance: float = 80.0
@export var max_orbit_distance: float = 250.0
@export var time_dilation_strength: float = 0.5
@export var time_dilation_range: float = 250.0
@export var time_dilation_cooldown: float = 5.0

var _orbit_angle: float = 0.0
var _orbit_direction: int = 1
var _players_in_dilation: Array = []
var _current_time_scale: float = 1.0
var _dilation_cooldown_timer: float = 0.0
var _is_dilating: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var time_dilation_area: Area2D = $GravityArea

func _ready() -> void:
	super._ready()
	
	if time_dilation_area:
		time_dilation_area.body_entered.connect(_on_time_dilation_area_entered)
		time_dilation_area.body_exited.connect(_on_time_dilation_area_exited)

func _process_movement(delta: float) -> void:
	if not _target:
		return
	
	var to_target = _target.global_position - global_position
	var distance_to_player = to_target.length()
	var direction_to_player = to_target.normalized()
	
	_orbit_angle += orbit_speed * _orbit_direction * delta
	
	var orbit_offset = Vector2.from_angle(_orbit_angle) * orbit_radius
	
	var linear_approach = direction_to_player * approach_speed
	
	velocity = linear_approach + orbit_offset
	
	position += velocity * delta

func _process_behavior(delta: float) -> void:
	_dilation_cooldown_timer = maxf(0.0, _dilation_cooldown_timer - delta)
	_apply_time_dilation(delta)

func _apply_time_dilation(_delta: float) -> void:
	if _dilation_cooldown_timer > 0 or _players_in_dilation.is_empty():
		return
	
	for player_ref in _players_in_dilation:
		var player = weakref(player_ref).get_ref()
		if player and is_instance_valid(player):
			var to_target = player.global_position - global_position
			var target_distance = to_target.length()
			
			if target_distance < time_dilation_range:
				_dilation_cooldown_timer = time_dilation_cooldown
				_apply_time_scale_to_player(player, time_dilation_strength)
				break

func _apply_time_scale_to_player(player: Node, time_scale: float) -> void:
	if player and player.movement:
		player.movement.apply_slow(time_scale)
		
		await get_tree().create_timer(2.0).timeout
		
		if is_instance_valid(player) and player.movement:
			player.movement.apply_slow(1.0)

func _on_time_dilation_area_entered(body: Node) -> void:
	if body is Player and not _players_in_dilation.has(body):
		_players_in_dilation.append(body)

func _on_time_dilation_area_exited(body: Node) -> void:
	if body is Player:
		_players_in_dilation.erase(body)

func reverse_direction() -> void:
	_orbit_direction *= -1

func _draw() -> void:
	draw_arc(Vector2.ZERO, orbit_radius, 0, TAU, 32, Color(0.2, 0.5, 1.0, 0.3), 2.0)
	
	var dilation_alpha = 0.3 if _dilation_cooldown_timer <= 0 else 0.1
	draw_circle(Vector2.ZERO, time_dilation_range * 0.5, Color(0.3, 0.3, 1.0, dilation_alpha))
	draw_arc(Vector2.ZERO, time_dilation_range, 0, TAU, 24, Color(0.4, 0.6, 1.0, dilation_alpha * 0.5), 1.5)
	
	var arrow_dir = Vector2.from_angle(_orbit_angle + PI * 0.5 * _orbit_direction)
	draw_line(Vector2.ZERO, arrow_dir * 20, Color.CYAN, 3.0)

func _on_activated() -> void:
	super._on_activated()
	if _target:
		_orbit_angle = global_position.angle_to_point(_target.global_position)
	_orbit_direction = 1 if randf() > 0.5 else -1
	_players_in_dilation.clear()
	_dilation_cooldown_timer = 0.0
	
	if sprite:
		sprite.play("orbit")

func _on_deactivated() -> void:
	super._on_deactivated()
	_orbit_angle = 0.0
	_players_in_dilation.clear()
	_dilation_cooldown_timer = 0.0
