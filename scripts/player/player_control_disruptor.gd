extends Node
class_name PlayerControlDisruptor

signal disruption_started
signal disruption_ended

@export var scramble_strength: float = 0.5
@export var screen_flash_color: Color = Color(0.8, 0.2, 0.2, 0.3)

var _is_disrupted: bool = false
var _disruption_timer: float = 0.0
var _disruption_duration: float = 0.0
var _player_ref: WeakRef = null
var _screen_flash: ColorRect

func _ready() -> void:
	_setup_screen_flash.call_deferred()

func _setup_screen_flash() -> void:
	var canvas = CanvasLayer.new()
	canvas.name = "DisruptFlash"
	canvas.layer = 100
	get_tree().root.add_child(canvas)
	
	_screen_flash = ColorRect.new()
	_screen_flash.color = screen_flash_color
	_screen_flash.visible = false
	_screen_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(_screen_flash)

func set_player(player: Node) -> void:
	_player_ref = weakref(player)

func disrupt(duration: float) -> void:
	if _is_disrupted:
		_disruption_duration += duration
		return
	
	_is_disrupted = true
	_disruption_duration = duration
	_disruption_timer = duration
	disruption_started.emit()
	
	if _screen_flash:
		_screen_flash.visible = true
		_screen_flash.color.a = 0.3
	
	var player = _player_ref.get_ref()
	if player and player.has_method("set_control_disrupted"):
		player.set_control_disrupted(true, scramble_strength)

func _process(delta: float) -> void:
	if not _is_disrupted:
		return
	
	_disruption_timer -= delta
	
	if _screen_flash:
		_screen_flash.color.a = sin(_disruption_timer * 10.0) * 0.15 + 0.15
	
	if _disruption_timer <= 0:
		_end_disruption()

func _end_disruption() -> void:
	_is_disrupted = false
	disruption_ended.emit()
	
	if _screen_flash:
		_screen_flash.visible = false
	
	var player = _player_ref.get_ref()
	if player and player.has_method("set_control_disrupted"):
		player.set_control_disrupted(false, 0.0)

func is_disrupted() -> bool:
	return _is_disrupted

func get_scramble_vector(base_input: Vector2) -> Vector2:
	if not _is_disrupted:
		return base_input
	
	var scramble = Vector2(
		randf_range(-scramble_strength, scramble_strength),
		randf_range(-scramble_strength, scramble_strength)
	)
	return base_input + scramble
