extends CharacterBody2D
class_name SubThread

## A smaller processing thread spawned from the player's Execution Pulse.
## It travels in a fixed direction for a limited time.

@export var lifetime: float = 0.8
@export var fade_time: float = 0.2
@export var speed: float = 200.0
@export var friction: float = 1.0

var _direction: Vector2 = Vector2.ZERO
var _timer: float = 0.0
var _is_dying: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Add some slight random rotation to the launch
	_direction = _direction.rotated(randf_range(-0.1, 0.1))

func setup(launch_direction: Vector2, parent_complexity: PlayerComplexity) -> void:
	_direction = launch_direction
	
	# Match some visuals from the parent
	if is_node_ready():
		_apply_visuals(parent_complexity)
	else:
		# Wait for ready if needed
		ready.connect(func(): _apply_visuals(parent_complexity), CONNECT_ONE_SHOT)

func _apply_visuals(data: PlayerComplexity) -> void:
	sprite.play(data.animation_name)
	sprite.modulate = data.color
	sprite.modulate.a = 0.4 # Lessened opacity for the "ghost" child
	# Sub-threads are always a bit smaller than the main thread at that tier
	sprite.scale = Vector2.ONE * data.scale * 0.7
	$CollisionShape2D.shape.size = data.collider_size * 0.7

func _physics_process(delta: float) -> void:
	if _is_dying:
		return
		
	_timer += delta
	
	# Apply movement with simple decay
	velocity = _direction * speed
	speed = move_toward(speed, 0.0, friction * delta * 100.0)
	
	move_and_slide()
	
	if _timer >= lifetime:
		_die()

func _die() -> void:
	_is_dying = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_time)
	tween.tween_callback(queue_free)
