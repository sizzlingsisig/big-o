extends BaseEnemy

@export_category("Stack Overflow Behavior")
@export var crush_speed: float = 100.0
@export var retreat_speed: float = 50.0
@export var crush_range: float = 80.0
@export var retreat_range: float = 350.0
@export var max_nested_blocks: int = 4

enum State { APPROACHING, CRUSHING, RETREATING }

var _state: State = State.APPROACHING
var _nested_blocks: int = 1
var _crush_timer: float = 0.0
var _crush_duration: float = 1.5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var block_container: Node2D = $BlockContainer

func _ready() -> void:
	super._ready()
	speed = crush_speed

func _process_movement(delta: float) -> void:
	match _state:
		State.APPROACHING:
			_process_approach(delta)
		State.CRUSHING:
			_process_crush(delta)
		State.RETREATING:
			_process_retreat(delta)
	position += velocity * delta

func _process_approach(_delta: float) -> void:
	if _target:
		var direction = (_target.global_position - global_position).normalized()
		velocity = direction * crush_speed

func _process_crush(delta: float) -> void:
	velocity = Vector2.ZERO
	_crush_timer -= delta
	
	var pulse_scale = 1.0 + sin(_crush_timer * 10.0) * 0.1
	scale = Vector2.ONE * (1.0 + _nested_blocks * 0.3) * pulse_scale
	
	if _crush_timer <= 0:
		_start_retreat()

func _process_retreat(_delta: float) -> void:
	if _target:
		var away_direction = (global_position - _target.global_position).normalized()
		velocity = away_direction * retreat_speed
		
		var distance = global_position.distance_to(_target.global_position)
		if distance > retreat_range:
			_start_approach()

func _process_behavior(_delta: float) -> void:
	if not _target or _state != State.APPROACHING:
		return
	
	var distance = global_position.distance_to(_target.global_position)
	if distance <= crush_range:
		_start_crush()

func _start_crush() -> void:
	_state = State.CRUSHING
	_crush_timer = _crush_duration
	_nested_blocks = mini(max_nested_blocks, _nested_blocks + 1)
	
	if sprite:
		sprite.play("crush")

func _start_retreat() -> void:
	_state = State.RETREATING
	
	if sprite:
		sprite.play("retreat")

func _start_approach() -> void:
	_state = State.APPROACHING
	
	if sprite:
		sprite.play("approach")

func _draw() -> void:
	var block_size = 30.0
	for i in range(_nested_blocks):
		var offset = i * block_size * 0.3
		var color = Color(
			0.8 - i * 0.1,
			0.2 + i * 0.1,
			0.1,
			1.0 - i * 0.15
		)
		var rect = Rect2(
			-block_size * 0.5 - offset,
			-block_size * 0.5 - offset,
			block_size + offset * 2,
			block_size + offset * 2
		)
		draw_rect(rect, color, false, 2.0)

func _on_activated() -> void:
	super._on_activated()
	_state = State.APPROACHING
	_nested_blocks = 1
	_crush_timer = 0.0
	scale = Vector2.ONE
	
	if sprite:
		sprite.play("approach")

func _on_deactivated() -> void:
	super._on_deactivated()
	_state = State.APPROACHING
	_nested_blocks = 1
	_crush_timer = 0.0
	scale = Vector2.ONE
