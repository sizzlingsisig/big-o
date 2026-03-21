extends Node
class_name MovementComponent

## Component responsible for mouse-drift physics.
## Attachment: Should be a child of the Player (CharacterBody2D).

@onready var parent: CharacterBody2D = get_parent() as CharacterBody2D

## The direction the player is currently facing or moving towards.
var facing_direction: Vector2 = Vector2.RIGHT

var _input_history: Array[Dictionary] = [] # Array of {time: float, pos: Vector2}

func _ready() -> void:
	if not parent:
		push_error("MovementComponent must be a child of a CharacterBody2D!")

## Updates the parent's velocity based on the target position and current complexity stats.
func process_movement(delta: float, target_pos: Vector2, current_complexity: PlayerComplexity) -> void:
	if not parent or not current_complexity:
		return
		
	# 1. Store the current target position with a timestamp
	var current_time: float = Time.get_ticks_msec() / 1000.0
	_input_history.append({"time": current_time, "pos": target_pos})
	
	# 2. Find the delayed target position based on input_lag
	var delayed_target: Vector2 = target_pos # Fallback
	var lag_threshold: float = current_time - current_complexity.input_lag
	
	# Remove entries that are older than the lag threshold, except the most recent one we need
	while _input_history.size() > 1 and _input_history[0].time < lag_threshold:
		delayed_target = _input_history[0].pos
		_input_history.remove_at(0)
	
	# If we still have a history, the first element is the closest to the lag target
	if not _input_history.is_empty():
		delayed_target = _input_history[0].pos

	var target_direction: Vector2 = (delayed_target - parent.global_position).normalized()
	
	# Update facing direction if we are actually moving
	if target_direction.length() > 0.0:
		facing_direction = target_direction

	# Stop moving if we are extremely close to the cursor to prevent "jitter"
	if parent.global_position.distance_to(delayed_target) < 8.0:
		target_direction = Vector2.ZERO

	# Agar.io Drift Logic:
	# We use (1.0 - inertia) to determine how fast we reach the target velocity.
	# O(2^n) has 0.9 inertia -> 0.1 weight (Very heavy/drifty)
	# O(1) has 0.0 inertia -> 1.0 weight (Instant/snappy)
	var lerp_weight: float = clamp((1.0 - current_complexity.inertia) * delta * 10.0, 0.0, 1.0)
	
	parent.velocity = parent.velocity.lerp(target_direction * current_complexity.speed, lerp_weight)
	
	# Perform the actual move
	parent.move_and_slide()

## Applies a sudden burst of velocity in a specific direction.
func apply_impulse(direction: Vector2, force: float) -> void:
	if parent:
		parent.velocity += direction * force
