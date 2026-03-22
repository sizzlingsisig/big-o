extends Resource
class_name EnemyConfig

@export_group("Identity")
@export var enemy_name: String = "Enemy"
@export var animation_name: String = "default"
@export var color: Color = Color.RED

@export_group("Stats")
@export var max_health: float = 3.0
@export var speed: float = 100.0
@export var damage: float = 1.0
@export var contact_damage: float = 1.0
@export var points: int = 100

@export_group("Spawning")
@export var spawn_weight: float = 1.0
@export var min_wave: int = 1
@export var max_count: int = 5
