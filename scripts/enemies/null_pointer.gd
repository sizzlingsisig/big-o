extends BaseEnemy

@export_category("Null Pointer Behavior")
@export var move_speed: float = 280.0

var _direction: Vector2 = Vector2.ZERO
var _initialized: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready()

func activate(target: Node2D) -> void:
	_direction = Vector2.ZERO
	_initialized = false
	super.activate(target)

func _process_movement(delta: float) -> void:
	if _target and not _initialized:
		_direction = (_target.global_position - global_position).normalized()
		_initialized = true
	
	if _direction != Vector2.ZERO:
		rotation = _direction.angle()
	
	velocity = _direction * move_speed
	position += velocity * delta

func _process_behavior(_delta: float) -> void:
	pass

func _on_activated() -> void:
	super._on_activated()
	_direction = Vector2.ZERO
	_initialized = false
	rotation = 0.0

func _on_deactivated() -> void:
	super._on_deactivated()
	_direction = Vector2.ZERO
	_initialized = false

func _on_area_entered(_area: Area2D) -> void:
	pass

func _on_body_entered(body: Node) -> void:
	if body is Player and not _has_hit_player:
		_has_hit_player = true
		body.take_damage(contact_damage)
		body.add_ram(ram_damage)
		die()
