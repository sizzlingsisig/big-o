extends CharacterBody2D
class_name Player

enum State { IDLE, PROCESSING, DISRUPTED, ERROR, FORKING, DEAD }

signal state_changed(new_state: State, old_state: State)
signal error_started
signal error_ended
signal fork_started
signal fork_ended
signal thread_forked(thread: SubThread)

@export_category("Components")
@export var movement: MovementComponent
@export var complexity: ComplexityManager
@export var visuals: VisualsComponent
@export var system_resources: SystemResourcesComponent

@export_category("The Fork")
@export var sub_thread_scene: PackedScene
@export var split_cooldown: float = 2.0

@export_category("Status Effects")
@export var control_disruptor: Node

@export_category("State Durations")
@export var error_duration: float = 0.5
@export var fork_duration: float = 0.3

var _state: State = State.IDLE
var _state_timer: float = 0.0
var _disruption_timer: float = 0.0
var _disruption_duration: float = 2.0

var _can_split: bool = true
var _is_invulnerable: bool = false
var _error_label: Label
var _shields: int = 0

@onready var split_timer: Timer = $SplitCooldown

func _ready() -> void:
	add_to_group("player")
	
	if not movement or not complexity or not visuals:
		push_error("Player: Missing component assignments in the Inspector!")
		return
	
	_setup_error_label()
	
	complexity.complexity_changed.connect(_on_complexity_changed)
	complexity.optimization_ready.connect(_on_optimization_ready)
	
	visuals.update_visuals(complexity.get_current_complexity())
	
	if control_disruptor and control_disruptor.has_method("set_player"):
		control_disruptor.set_player(self)
	
	_change_state(State.IDLE)
	GameEvents.player_spawned.emit(self)

func _setup_error_label() -> void:
	_error_label = Label.new()
	_error_label.text = "ERROR"
	_error_label.add_theme_color_override("font_color", Color.RED)
	_error_label.add_theme_font_size_override("font_size", 24)
	_error_label.position = Vector2(-30, -60)
	_error_label.modulate.a = 0.0
	add_child(_error_label)

func _physics_process(delta: float) -> void:
	_update_state_timer(delta)
	_update_disruption(delta)
	
	match _state:
		State.IDLE:
			_process_idle(delta)
		State.PROCESSING:
			_process_idle(delta)
			_update_processing(delta)
		State.DISRUPTED:
			_process_disrupted(delta)
		State.ERROR:
			pass
		State.FORKING:
			pass
		State.DEAD:
			pass

func _update_state_timer(delta: float) -> void:
	if _state_timer > 0:
		_state_timer -= delta
		
		if _state_timer <= 0:
			_on_state_timer_expired()

func _update_disruption(delta: float) -> void:
	if _state == State.DISRUPTED:
		_disruption_timer -= delta
		visuals.apply_disruption_effect(_disruption_timer / _disruption_duration)
		
		if _disruption_timer <= 0:
			if _state == State.DISRUPTED:
				_change_state(State.IDLE)

func _process_idle(delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	movement.process_movement(delta, mouse_pos, complexity.get_current_complexity())

func _process_disrupted(delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	movement.process_movement(delta, mouse_pos, complexity.get_current_complexity())

func _update_processing(_delta: float) -> void:
	visuals.apply_processing_effect()

func _on_state_timer_expired() -> void:
	match _state:
		State.PROCESSING:
			_complete_processing()
		State.ERROR:
			_end_error()
		State.FORKING:
			_end_forking()

func _change_state(new_state: State) -> void:
	var old_state = _state
	_state = new_state
	
	_exit_state(old_state)
	_enter_state(new_state)
	state_changed.emit(new_state, old_state)
	GameEvents.player_state_changed.emit(new_state, old_state)

func _enter_state(state: State) -> void:
	match state:
		State.IDLE:
			visuals.set_state(State.IDLE)
		State.PROCESSING:
			visuals.set_state(State.PROCESSING)
			var duration = complexity.get_processing_time()
			_state_timer = duration
		State.DISRUPTED:
			visuals.set_state(State.DISRUPTED)
		State.ERROR:
			_start_error()
		State.FORKING:
			visuals.set_state(State.FORKING)
			_state_timer = fork_duration
			_is_invulnerable = true
		State.DEAD:
			visuals.set_state(State.DEAD)

func _exit_state(state: State) -> void:
	match state:
		State.PROCESSING:
			if _state != State.PROCESSING:
				visuals.clear_processing_effect()
		State.DISRUPTED:
			visuals.clear_disruption_effect()
		State.ERROR:
			visuals.clear_error_effect()
		State.FORKING:
			visuals.clear_forking_effect()
		State.DEAD:
			pass
		State.IDLE:
			pass

func _start_error() -> void:
	error_started.emit()
	ScreenFX.shake(5.0, 0.3)
	
	if _error_label:
		_error_label.modulate.a = 1.0
		var tween = create_tween()
		tween.tween_interval(error_duration * 0.6)
		tween.tween_property(_error_label, "modulate:a", 0.0, 0.2)

func _end_error() -> void:
	_error_label.modulate.a = 0.0
	error_ended.emit()
	visuals.clear_error_effect()
	_change_state(State.IDLE)

func _input(event: InputEvent) -> void:
	if _state == State.DEAD or _state == State.ERROR or _state == State.FORKING:
		return
	
	if _state == State.PROCESSING:
		return
	
	if event.is_action_pressed("ui_accept"):
		if _can_split:
			_zombie_fork()
		else:
			print("System recovering from previous fork...")
	
	if OS.is_debug_build():
		if event.is_action_pressed("ui_up"):
			start_processing()
		if event.is_action_pressed("ui_down"):
			complexity.accumulate_debt()

func start_processing() -> void:
	if _state == State.DEAD or _state == State.PROCESSING:
		return
	
	var duration = complexity.get_processing_time()
	
	if duration <= 0:
		_complete_processing()
		return
	
	_change_state(State.PROCESSING)

func _complete_processing() -> void:
	visuals.clear_processing_effect()
	complexity.refactor()
	clear_ram(5.0)
	_change_state(State.IDLE)

func _zombie_fork() -> void:
	if not sub_thread_scene:
		push_warning("Player: Sub-Thread scene not assigned!")
		return
	
	var current_data = complexity.get_current_complexity()
	
	if complexity.accumulate_debt():
		fork_started.emit()
		_change_state(State.FORKING)
		
		var sub_thread = sub_thread_scene.instantiate() as SubThread
		var launch_dir: Vector2 = movement.facing_direction
		sub_thread.setup(launch_dir, current_data)
		sub_thread.global_position = global_position
		thread_forked.emit(sub_thread)
		
		var impulse_force: float = minf(current_data.speed * 2.0, 300.0)
		movement.apply_impulse(launch_dir, impulse_force)
		
		clear_ram(20.0)
		_can_split = false
		split_timer.start(split_cooldown)

func _end_forking() -> void:
	fork_ended.emit()
	_is_invulnerable = false
	_change_state(State.IDLE)

func _on_split_cooldown_timeout() -> void:
	_can_split = true

func _on_complexity_changed(new_data: PlayerComplexity) -> void:
	visuals.update_visuals(new_data)

func _on_optimization_ready() -> void:
	start_processing()

func set_control_disrupted(disrupted: bool, duration: float) -> void:
	if disrupted:
		_disruption_duration = duration
		_disruption_timer = duration
		if _state != State.PROCESSING and _state != State.DEAD:
			_change_state(State.DISRUPTED)
	else:
		if _state == State.DISRUPTED:
			_change_state(State.IDLE)

func take_damage(amount: float) -> void:
	if _is_invulnerable or _state == State.DEAD:
		return
	
	if complexity:
		for i in range(int(amount)):
			complexity.accumulate_debt()
	
	_change_state(State.ERROR)
	_state_timer = error_duration

func add_ram(amount: float) -> void:
	if system_resources:
		system_resources.add_ram(amount)

func clear_ram(amount: float = 20.0) -> void:
	if system_resources:
		system_resources.clear_ram(amount)

func add_shields(amount: int) -> void:
	_shields += amount
	print("Player picked up shields. Total shields: ", _shields)

func consume_shield() -> bool:
	if _shields > 0:
		_shields -= 1
		print("Player consumed a shield. Remaining shields: ", _shields)
		return true
	return false

func apply_external_force(force: Vector2) -> void:
	if movement:
		movement.apply_external_force(force)

func trigger_dead() -> void:
	if _state == State.DEAD:
		return
	_change_state(State.DEAD)
	GameEvents.player_died.emit()
