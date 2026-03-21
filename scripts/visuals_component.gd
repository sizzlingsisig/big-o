extends Node
class_name VisualsComponent

## Component responsible for the player's visual state and transitions.
## Handles AnimatedSprite2D playback, smooth scaling, and collider resizing.

@export_group("Nodes")
## The AnimatedSprite2D used for tier-based animations.
@export var sprite: AnimatedSprite2D
## The CollisionShape2D (RectangleShape2D) to resize.
@export var collision_shape: CollisionShape2D

@export_group("Settings")
## Time in seconds for transitions between tiers.
@export var transition_time: float = 0.25

var _active_tween: Tween

func _ready() -> void:
	if not sprite or not collision_shape:
		push_warning("VisualsComponent: Sprite or CollisionShape not assigned!")

## Updates all visual aspects based on the new complexity tier.
func update_visuals(data: PlayerComplexity) -> void:
	if not data:
		return
		
	# 1. Play the matching animation (exponential, constant, etc.)
	if sprite:
		if sprite.sprite_frames.has_animation(data.animation_name):
			sprite.play(data.animation_name)
		else:
			push_warning("VisualsComponent: Animation '" + data.animation_name + "' not found!")

	# 2. Smoothly transition scale, color, and collision size
	_run_transition_tween(data)

func _run_transition_tween(data: PlayerComplexity) -> void:
	if _active_tween:
		_active_tween.kill()
	
	_active_tween = create_tween().set_parallel(true)
	_active_tween.set_trans(Tween.TRANS_CUBIC)
	_active_tween.set_ease(Tween.EASE_OUT)
	
	# Tween the sprite's scale and color
	if sprite:
		_active_tween.tween_property(sprite, "scale", Vector2.ONE * data.scale, transition_time)
		_active_tween.tween_property(sprite, "modulate", data.color, transition_time)
	
	# Tween the RectangleShape2D size and offset
	if collision_shape and collision_shape.shape is RectangleShape2D:
		_active_tween.tween_property(collision_shape.shape, "size", data.collider_size, transition_time)
		_active_tween.tween_property(collision_shape, "position", data.collider_offset, transition_time)

## Placeholder for the "Deep-Fry" shader integration
func update_ram_heat(heat_percent: float) -> void:
	# This will be linked to shader parameters later
	pass
