extends Node

signal shake_finished

var _shake_timer: float = 0.0
var _shake_intensity: float = 0.0
var _camera: Camera2D

func _ready() -> void:
	_camera = get_tree().root.get_camera_2d()

func shake(intensity: float, duration: float) -> void:
	_shake_intensity = intensity
	_shake_timer = duration

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
