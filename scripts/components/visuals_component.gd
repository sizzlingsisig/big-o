extends Node
class_name VisualsComponent

## Component responsible for the player's visual state and transitions.
## Handles AnimatedSprite2D playback, smooth scaling, collider resizing, and state effects.

@export_group("Nodes")
@export var sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D

@export_group("Settings")
@export var transition_time: float = 0.25

var _current_state: int = -1
var _active_tween: Tween
var _state_tween: Tween
var _base_modulate: Color = Color.WHITE
var _base_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	if not sprite or not collision_shape:
		push_warning("VisualsComponent: Sprite or CollisionShape not assigned!")

func update_visuals(data: PlayerComplexity) -> void:
	if not data:
		return
		
	if sprite:
		if sprite.sprite_frames.has_animation(data.animation_name):
			sprite.play(data.animation_name)
		else:
			push_warning("VisualsComponent: Animation '" + data.animation_name + "' not found!")
	
	_base_modulate = data.color if data.color else Color.WHITE
	_base_scale = Vector2.ONE * (data.scale if data.scale else 1.0)
	
	_run_transition_tween(data)

func _run_transition_tween(data: PlayerComplexity) -> void:
	if _active_tween:
		_active_tween.kill()
	
	_active_tween = create_tween().set_parallel(true)
	_active_tween.set_trans(Tween.TRANS_CUBIC)
	_active_tween.set_ease(Tween.EASE_OUT)
	
	if sprite:
		_active_tween.tween_property(sprite, "scale", Vector2.ONE * data.scale, transition_time)
		_active_tween.tween_property(sprite, "modulate", data.color, transition_time)
	
	if collision_shape and collision_shape.shape is RectangleShape2D:
		_active_tween.tween_property(collision_shape.shape, "size", data.collider_size, transition_time)
		_active_tween.tween_property(collision_shape, "position", data.collider_offset, transition_time)

func set_state(state: int) -> void:
	_current_state = state

func apply_processing_effect() -> void:
	if not sprite:
		return
	
	var flicker = 1.0 + sin(Time.get_ticks_msec() * 0.025) * 0.3
	sprite.modulate = _base_modulate * flicker

func apply_processing_interrupted_effect() -> void:
	if not sprite:
		return
	
	_state_tween = create_tween().set_parallel(true)
	_state_tween.tween_property(sprite, "modulate", Color.ORANGE, 0.1)
	_state_tween.tween_property(sprite, "scale", _base_scale * 0.8, 0.1)
	_state_tween.tween_interval(0.15)
	_state_tween.tween_property(sprite, "modulate", _base_modulate, 0.3)
	_state_tween.tween_property(sprite, "scale", _base_scale, 0.3)

func clear_processing_effect() -> void:
	if sprite:
		sprite.modulate = _base_modulate

func apply_interrupted_effect() -> void:
	apply_processing_interrupted_effect()

func apply_disruption_effect(intensity: float) -> void:
	if not sprite:
		return
	
	intensity = clampf(intensity, 0.0, 1.0)
	
	var r_offset = randf_range(-3.0 * intensity, 3.0 * intensity)
	var b_offset = randf_range(-3.0 * intensity, 3.0 * intensity)
	
	sprite.modulate.r = clampf(_base_modulate.r + r_offset * 0.5, 0.0, 2.0)
	sprite.modulate.g = _base_modulate.g * 0.5
	sprite.modulate.b = clampf(_base_modulate.b + b_offset * 0.5, 0.0, 2.0)

func clear_disruption_effect() -> void:
	if sprite:
		sprite.modulate = _base_modulate

func apply_error_effect() -> void:
	if not sprite:
		return
	
	_state_tween = create_tween().set_parallel(true)
	_state_tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	_state_tween.tween_interval(0.3)
	_state_tween.tween_property(sprite, "modulate", _base_modulate, 0.2)

func clear_error_effect() -> void:
	if _state_tween:
		_state_tween.kill()
	if sprite:
		sprite.modulate = _base_modulate

func apply_forking_effect() -> void:
	if not sprite:
		return
	
	_state_tween = create_tween().set_parallel(true)
	_state_tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	_state_tween.tween_property(sprite, "scale", _base_scale * 1.2, 0.15)
	_spawn_ghost()

func _spawn_ghost() -> void:
	if not sprite:
		return
	
	var ghost = Sprite2D.new()
	ghost.texture = sprite.sprite_frames.get_frame(sprite.animation, sprite.frame)
	ghost.position = sprite.position
	ghost.modulate = sprite.modulate
	ghost.modulate.a = 0.3
	ghost.scale = sprite.scale * 1.1
	get_tree().current_scene.add_child(ghost)
	
	var tween = create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.3)
	tween.tween_property(ghost, "position", ghost.position + Vector2(-20, -20), 0.3)
	tween.tween_callback(ghost.queue_free)

func clear_forking_effect() -> void:
	if _state_tween:
		_state_tween.kill()
	if sprite:
		sprite.modulate = _base_modulate
		sprite.scale = _base_scale

func apply_dead_effect() -> void:
	if not sprite:
		return
	
	_state_tween = create_tween().set_parallel(true)
	_state_tween.tween_property(sprite, "modulate", Color.GRAY, 0.5)
	_state_tween.tween_property(sprite, "modulate:a", 0.5, 1.0)

func update_ram_heat(_heat_percent: float) -> void:
	# Reserved for shader-based heat effects in future
	pass
