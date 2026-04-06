extends BaseEnemy

@export_category("Null Pointer Behavior")
@export var move_speed: float = 280.0

var _direction: Vector2 = Vector2.ZERO
var _initialized: bool = false
var _travel_audio: AudioStreamPlayer2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready()
	_setup_travel_audio()

func _setup_travel_audio() -> void:
	_travel_audio = AudioStreamPlayer2D.new()
	_travel_audio.stream = preload("res://assets/audio/null_pointer_travelling.ogg")
	_travel_audio.bus = "Master"
	_travel_audio.autoplay = false
	add_child(_travel_audio)
	_travel_audio.finished.connect(_on_travel_audio_finished)

func _on_travel_audio_finished() -> void:
	if _is_on_screen and _travel_audio:
		_travel_audio.play()

func _on_screen_entered() -> void:
	super._on_screen_entered()
	if _travel_audio:
		_travel_audio.play()

func _on_screen_exited() -> void:
	super._on_screen_exited()
	if _travel_audio:
		_travel_audio.stop()

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
