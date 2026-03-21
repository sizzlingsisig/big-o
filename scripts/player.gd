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

var _can_split: bool = true
@onready var split_timer: Timer = $SplitCooldown

func _ready() -> void:
	if not movement or not complexity or not visuals:
		push_error("Player: Missing component assignments in the inspector!")
		return
		
	# Connect signals: When complexity changes, update the visuals.
	complexity.complexity_changed.connect(_on_complexity_changed)
	
	# Initial visual update
	visuals.update_visuals(complexity.get_current_complexity())

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
	else:
		print("Cannot fork: System is already at maximum O(2^n) bloat!")

func _on_split_cooldown_timeout() -> void:
	_can_split = true
	print("Ready to fork again.")

func _on_complexity_changed(new_data: PlayerComplexity) -> void:
	# Update visuals when we move between Big O tiers
	visuals.update_visuals(new_data)
