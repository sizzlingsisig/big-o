extends CharacterBody2D
class_name Player

## Main controller for the Execution Pulse.
## This script acts as a "Manager" that delegates logic to child components.

@export_category("Components")
@export var movement: MovementComponent
@export var complexity: ComplexityManager
@export var visuals: VisualsComponent

## Emitted when the player splits/forks a thread. The listener should add the thread to the scene tree.
signal thread_forked(thread: SubThread)

@export_category("The Fork")
@export var sub_thread_scene: PackedScene
@export var split_cooldown: float = 2.0

@export_category("Status Effects")
@export var control_disruptor: Node

var _can_split: bool = true
var _control_disrupted: bool = false
var _disruption_strength: float = 0.0
@onready var split_timer: Timer = $SplitCooldown

var _ram_meter: Node
var _hit_error_label: Label
var _original_modulate: Color = Color.WHITE
var _is_hit_flashing: bool = false

func _ready() -> void:
	if not movement or not complexity or not visuals:
		push_error("Player: Missing component assignments in the Inspector!")
		return
		
	_setup_error_label()
	
	# Connect signals: When complexity changes, update the visuals.
	complexity.complexity_changed.connect(_on_complexity_changed)
	
	# Initial visual update
	visuals.update_visuals(complexity.get_current_complexity())
	
	# Setup control disruptor
	if control_disruptor and control_disruptor.has_method("set_player"):
		control_disruptor.set_player(self)
	
	# Setup RAM meter
	_ram_meter = get_node_or_null("../HUD/Control/RAMMeter")
	if not _ram_meter:
		_ram_meter = get_tree().get_first_node_in_group("ram_meter")

func _setup_error_label() -> void:
	_hit_error_label = Label.new()
	_hit_error_label.text = "ERROR"
	_hit_error_label.add_theme_color_override("font_color", Color.RED)
	_hit_error_label.add_theme_font_size_override("font_size", 24)
	_hit_error_label.position = Vector2(-30, -60)
	_hit_error_label.modulate.a = 0.0
	add_child(_hit_error_label)

func _physics_process(delta: float) -> void:
	# Delegate movement to the MovementComponent
	# We pass the mouse position and the current complexity resource
	var mouse_pos: Vector2 = get_global_mouse_position()
	movement.process_movement(delta, mouse_pos, complexity.get_current_complexity())

func _input(event: InputEvent) -> void:
	# "The Zombie Fork"
	# Description: Throw your child to death; his ghost lingers in your system, bloating your execution.
	if event.is_action_pressed("ui_accept"): # Default Spacebar
		if _can_split:
			_zombie_fork()
		else:
			print("System recovering from previous fork...")
		
	# DEBUG: Manual Refactor (testing purposes)
	if OS.is_debug_build() and event.is_action_pressed("ui_up"):
		complexity.refactor()
	# DEBUG: Manual Debt (testing purposes)
	if OS.is_debug_build() and event.is_action_pressed("ui_down"):
		complexity.accumulate_debt()

func _zombie_fork() -> void:
	if not sub_thread_scene:
		push_warning("Player: Sub-Thread scene not assigned!")
		return
		
	# Store the current complexity to pass to the child
	var current_data = complexity.get_current_complexity()
	
	# 1. Accumulate Debt (Move to a slower/heavier tier)
	# This represents the "Ghost" lingering in the system.
	if complexity.accumulate_debt():
		print("Zombie Fork! Child process ejected. System bloat detected...")
		
		# 2. Start the cooldown
		_can_split = false
		split_timer.start(split_cooldown)
		
		# 3. Spawn the sub-thread (the child sent to its death)
		var sub_thread = sub_thread_scene.instantiate() as SubThread
		
		# 4. Launch it forward in the direction the player is currently facing
		var launch_dir: Vector2 = movement.facing_direction
		sub_thread.setup(launch_dir, current_data)
		
		# 5. Handle parenting
		if thread_forked.get_connections().size() > 0:
			# For decoupled spawning, we set position assuming the listener adds to World (0,0)
			# or handles the transform correction.
			sub_thread.global_position = global_position
			thread_forked.emit(sub_thread)
		else:
			# Fallback: Add as sibling
			get_parent().add_child(sub_thread)
			# MUST set global_position AFTER adding to tree to account for parent transform
			sub_thread.global_position = global_position
		
		# 6. Launch the PARENT forward as well (The recoil/kickback)
		movement.apply_impulse(launch_dir, current_data.speed * 5.0)
		
		# 7. Clear some RAM
		clear_ram(20.0)
	else:
		print("Cannot fork: System is already at maximum O(2^n) bloat!")

func _on_split_cooldown_timeout() -> void:
	_can_split = true
	print("Ready to fork again.")

func _on_complexity_changed(new_data: PlayerComplexity) -> void:
	# Update visuals when we move between Big O tiers
	visuals.update_visuals(new_data)

func set_control_disrupted(disrupted: bool, strength: float) -> void:
	_control_disrupted = disrupted
	_disruption_strength = strength
	if movement:
		movement.set_disrupted(disrupted, strength)

func take_damage(amount: float) -> void:
	if complexity:
		for i in range(int(amount)):
			complexity.accumulate_debt()
	_show_hit_feedback()

func add_ram(amount: float) -> void:
	if _ram_meter and _ram_meter.has_method("add_ram"):
		_ram_meter.add_ram(amount)

func clear_ram(amount: float = 20.0) -> void:
	if _ram_meter and _ram_meter.has_method("clear_ram"):
		_ram_meter.clear_ram(amount)

func apply_external_force(force: Vector2) -> void:
	if movement:
		movement.apply_external_force(force)

func _show_hit_feedback() -> void:
	if _is_hit_flashing:
		return
	_is_hit_flashing = true
	
	if visuals and visuals.sprite:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(visuals.sprite, "modulate", Color.RED, 0.1)
		tween.tween_interval(0.3)
		tween.tween_property(visuals.sprite, "modulate", _original_modulate, 0.2)
		tween.chain().tween_callback(func(): _is_hit_flashing = false)
	
	if _hit_error_label:
		var tween2 = create_tween().set_parallel(false)
		tween2.tween_property(_hit_error_label, "modulate:a", 1.0, 0.1)
		tween2.tween_interval(0.4)
		tween2.tween_property(_hit_error_label, "modulate:a", 0.0, 0.3)
