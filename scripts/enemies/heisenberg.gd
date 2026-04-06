extends BaseEnemy
class_name HeisenbergEnemy

@export_category("Heisenberg Behavior")
@export var teleport_range: float = 200.0
@export var teleport_cooldown: float = 4.0
@export var strike_damage: float = 15.0
@export var move_speed: float = 50.0

@export var min_teleport_distance: float = 180.0
@export var strike_delay: float = 0.12
var _strike_timer: float = 0.0

var _teleport_cooldown_timer: float = 0.0
var _is_teleporting: bool = false
var _teleport_count: int = 0
var _max_teleports: int = 3

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready()
	_teleport_cooldown_timer = teleport_cooldown * 0.5

func _process_movement(delta: float) -> void:
	if _is_teleporting:
		velocity = Vector2.ZERO
	else:
		_process_stalking(delta)
	position += velocity * delta

func _process_stalking(delta: float) -> void:
	if _target:
		var direction = (_target.global_position - global_position).normalized()
		velocity = velocity.lerp(direction * move_speed, delta * 2.0)

func _process_behavior(delta: float) -> void:
	_teleport_cooldown_timer = maxf(0.0, _teleport_cooldown_timer - delta)
	if _strike_timer > 0:
		_strike_timer -= delta
		if _strike_timer <= 0:
			_attempt_strike()
	elif _teleport_cooldown_timer <= 0 and _teleport_count < _max_teleports:
		_trigger_teleport()

func _trigger_teleport() -> void:
	if not _target:
		return
	_is_teleporting = true
	GameEvents.heisenberg_teleporting.emit()
	_teleport_count += 1
	_teleport_cooldown_timer = teleport_cooldown
	var attempts = 0
	var teleport_pos = global_position
	while attempts < 8:
		var behind_offset = (_target.global_position - global_position).normalized() * -100.0
		var random_offset = Vector2(randf_range(-80, 80), randf_range(-80, 80))
		teleport_pos = _target.global_position + behind_offset + random_offset
		if teleport_pos.distance_to(_target.global_position) >= min_teleport_distance:
			break
		attempts += 1
	teleport_pos = _target.global_position + (_target.global_position - global_position).normalized() * -min_teleport_distance
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		global_position = teleport_pos
	)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	tween.tween_callback(func():
		_is_teleporting = false
		_strike_timer = strike_delay
	)


func _attempt_strike() -> void:
	if not _target:
		return
	
	var distance = global_position.distance_to(_target.global_position)
	if distance <= 100.0:
		_target.take_damage(strike_damage)
		_target.add_ram(ram_damage)

func _on_activated() -> void:
	super._on_activated()
	_is_teleporting = false
	_teleport_count = 0
	_teleport_cooldown_timer = teleport_cooldown * 0.5
	
	if sprite:
		sprite.modulate = Color.WHITE

func _on_deactivated() -> void:
	super._on_deactivated()
	_is_teleporting = false
	_teleport_count = 0
	_teleport_cooldown_timer = 0.0
	
	if sprite:
		sprite.modulate = Color.WHITE
