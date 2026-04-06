extends Area2D
class_name BaseEnemy

signal damaged(amount: float)
signal died(enemy: BaseEnemy)

@export_category("Configuration")
@export var config: EnemyConfig

@export_category("Components")
@export var health_component: EnemyHealthComponent

@export_group("Stats")
@export var speed: float = 100.0
@export var damage: float = 1.0
@export var contact_damage: float = 1.0
@export var ram_damage: float = 10.0
@export var free_on_screen_exit: bool = false

@export_group("Culling")
@export var cull_distance: float = 2500.0
@export var use_simplified_behavior_off_screen: bool = true

var _target: Node2D
var _is_active: bool = false
var _is_on_screen: bool = false
var _has_hit_player: bool = false
var _is_time_frozen: bool = false
var velocity: Vector2 = Vector2.ZERO

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	_setup_from_config()
	add_to_group("enemies")
	
	GameEvents.time_frozen_started.connect(_on_time_frozen_started)
	GameEvents.time_frozen_ended.connect(_on_time_frozen_ended)

	if health_component:
		health_component.health_depleted.connect(_on_health_depleted)

	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

	if screen_notifier:
		screen_notifier.screen_entered.connect(_on_screen_entered)
		screen_notifier.screen_exited.connect(_on_screen_exited)

func _on_time_frozen_started(_duration: float) -> void:
	_is_time_frozen = true
	
func _on_time_frozen_ended() -> void:
	_is_time_frozen = false

func _setup_from_config() -> void:
	if config:
		speed = config.speed
		damage = config.damage
		contact_damage = config.contact_damage
		if health_component:
			health_component.max_health = config.max_health

func _physics_process(delta: float) -> void:
	if not _is_active or _is_time_frozen:
		_process_simplified_behavior(delta)
	else:
		_process_movement(delta)
		_process_behavior(delta)
	
	_check_cull_distance()

func _process_movement(_delta: float) -> void:
	pass

func _process_behavior(_delta: float) -> void:
	pass

func _process_simplified_behavior(_delta: float) -> void:
	pass

func _check_cull_distance() -> void:
	if not _target or not is_instance_valid(_target):
		return
	
	var distance_to_target = global_position.distance_to(_target.global_position)
	if distance_to_target > cull_distance:
		print("[ENEMY] %s culled at distance %.0f" % [name, distance_to_target])
		die()

func activate(target: Node2D) -> void:
	_target = target
	_is_active = true
	_on_activated()

func deactivate() -> void:
	_is_active = false
	_has_hit_player = false
	_on_deactivated()

func _on_activated() -> void:
	visible = true

func _on_deactivated() -> void:
	visible = false
	_is_on_screen = false

func take_damage(amount: float) -> void:
	if health_component:
		health_component.take_damage(amount)
	else:
		die()
	damaged.emit(amount)

func die() -> void:
	_is_active = false
	_on_died()
	died.emit(self)

func _on_health_depleted() -> void:
	die()

func _on_died() -> void:
	queue_free()

func _on_area_entered(_area: Area2D) -> void:
	pass

func _on_body_entered(body: Node) -> void:
	if body is Player and not _has_hit_player:
		_has_hit_player = true
		
		if body.has_method("consume_shield") and body.consume_shield():
			print("[ENEMY] %s hit player shield! Absorbed!" % name)
			die()
			return
			
		print("[ENEMY] %s hit player! RAM +%.0f%%" % [name, ram_damage])
		
		# Decoupled interaction via Player methods or GameEvents
		if body.has_method("take_damage"):
			body.take_damage(contact_damage)
		if body.has_method("add_ram"):
			body.add_ram(ram_damage)
		GameEvents.enemy_hit.emit(name)
		die()

func _on_screen_exited() -> void:
	_is_on_screen = false

func _on_screen_entered() -> void:
	_is_on_screen = true

func apply_status_effect(effect_type: String, data: Dictionary) -> void:
	GameEvents.status_effect_applied.emit(effect_type, data)
