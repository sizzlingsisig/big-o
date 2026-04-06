extends Node

signal shake_finished

var _shake_timer: float = 0.0
var _shake_intensity: float = 0.0
var _camera: Camera2D
var _pending_camera: Camera2D = null

func _ready() -> void:
	pass

func register_camera(cam: Camera2D) -> void:
	_camera = cam
	_pending_camera = cam

func _get_active_camera() -> Camera2D:
	if _camera and is_instance_valid(_camera):
		return _camera
	
	if _pending_camera and is_instance_valid(_pending_camera):
		_camera = _pending_camera
		return _camera
	
	return null

func shake(intensity: float, duration: float) -> void:
	_shake_intensity = intensity
	_shake_timer = duration
	_camera = _get_active_camera()

func flash(color: Color, duration: float) -> void:
	var flash_rect = ColorRect.new()
	flash_rect.color = color
	flash_rect.anchors_preset = Control.PRESET_FULL_RECT
	flash_rect.modulate.a = 0.8
	
	var container = CanvasLayer.new()
	container.name = "FlashLayer"
	container.follow_viewport_enabled = true
	container.add_child(flash_rect)
	get_tree().root.add_child(container)
	
	var tween = create_tween()
	tween.tween_property(flash_rect, "modulate:a", 0.0, duration)
	tween.chain().tween_callback(flash_rect.queue_free)
	tween.chain().tween_callback(container.queue_free)

func glitch(_intensity: float, _duration: float) -> void:
	pass

func reset() -> void:
	_shake_timer = 0.0
	_shake_intensity = 0.0

func _process(delta: float) -> void:
	if _shake_timer > 0:
		_shake_timer -= delta
		
		if not _camera or not is_instance_valid(_camera):
			_camera = _get_active_camera()
		
		if _camera:
			var offset = Vector2(
				randf_range(-_shake_intensity, _shake_intensity),
				randf_range(-_shake_intensity, _shake_intensity)
			)
			_camera.offset = offset
		
		if _shake_timer <= 0:
			if _camera:
				_camera.offset = Vector2.ZERO
			shake_finished.emit()
