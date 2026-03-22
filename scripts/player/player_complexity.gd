extends Resource
## This resource defines the physics and visual properties for each algorithm tier.
class_name PlayerComplexity

@export_group("Identity")
## The name of the complexity tier (e.g., "O(1)", "O(n)", etc.).
@export var tier_name: String = "O(n)"
## The name of the animation in AnimatedSprite2D.
@export var animation_name: String = "linear"
## The color tint to use for the player sprite at this tier.
@export var color: Color = Color.WHITE

@export_group("Physics")
## The maximum movement speed in pixels/second.
@export var speed: float = 84.0
## Inertia value between 0.0 (snappy) and 1.0 (heavy drift/low friction).
@export_range(0.0, 1.0) var inertia: float = 0.5
## Input latency in seconds. Higher complexity has more lag.
@export var input_lag: float = 0.0
## The size of the RectangleShape2D collider.
@export var collider_size: Vector2 = Vector2(60, 60)
## The positional offset of the collider.
@export var collider_offset: Vector2 = Vector2(0, 0)

@export_group("Visuals")
## The visual scale multiplier for the Execution Pulse sprite.
@export var scale: float = 1.0
