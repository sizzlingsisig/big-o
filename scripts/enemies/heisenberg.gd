extends BaseEnemy

signal disrupted_player(duration: float)

@export_category("Heisenberg Behavior")
@export var disrupt_range: float = 180.0
@export var disrupt_duration: float = 2.0
@export var disrupt_cooldown: float = 8.0
@export var move_speed: float = 50.0

var _disrupt_cooldown_timer: float = 0.0
var _is_disrupting: bool = false
var _disrupt_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var disrupt_effect: Node2D = $DisruptEffect

func _ready() -> void:
	super._ready()
	_disrupt_cooldown_timer = disrupt_cooldown * 0.5

func _process_movement(delta: float) -> void:
	if _is_disrupting:
		velocity = velocity.lerp(Vector2.ZERO, delta * 10.0)
	else:
		_process_stalking(delta)
	position += velocity * delta

func _process_stalking(delta: float) -> void:
	if _target:
		var direction = (_target.global_position - global_position).normalized()
		velocity = velocity.lerp(direction * move_speed, delta * 2.0)

func _process_behavior(delta: float) -> void:
	if _is_disrupting:
		_process_disrupt(delta)
	elif _disrupt_cooldown_timer > 0:
		_disrupt_cooldown_timer -= delta
		_check_disrupt_trigger()

func _process_disrupt(delta: float) -> void:
	_disrupt_timer -= delta
	
	if sprite:
		sprite.modulate = Color(sin(_disrupt_timer * 10.0) * 0.5 + 0.5, 0.5, 0.5)
	
	if _disrupt_timer <= 0:
		_end_disrupt()

func _check_disrupt_trigger() -> void:
	if not _target:
		return
	
	var distance = global_position.distance_to(_target.global_position)
	if distance <= disrupt_range and _disrupt_cooldown_timer <= 0:
		_trigger_disrupt()

func _trigger_disrupt() -> void:
	_is_disrupting = true
	_disrupt_timer = disrupt_duration
	disrupted_player.emit(disrupt_duration)
	
	if disrupt_effect:
		disrupt_effect.trigger()
	
	if sprite:
		sprite.play("disrupt")

func _end_disrupt() -> void:
	_is_disrupting = false
	_disrupt_cooldown_timer = disrupt_cooldown
	
	if sprite:
		sprite.play("idle")
		sprite.modulate = Color.WHITE

func _on_activated() -> void:
	super._on_activated()
	_is_disrupting = false
	_disrupt_timer = 0.0
	_disrupt_cooldown_timer = disrupt_cooldown * 0.5
	
	if sprite:
		sprite.modulate = Color.WHITE

func _on_deactivated() -> void:
	super._on_deactivated()
	_is_disrupting = false
	_disrupt_timer = 0.0
	_disrupt_cooldown_timer = 0.0
	
	if sprite:
		sprite.modulate = Color.WHITE
