extends Node

## Global Event Bus for "Big O: Technical Debt".
## Handles decoupled communication between game systems.
## Signals are emitted by various systems and connected by consumers (HUD, World, etc.).

# --- Player Signals ---
@warning_ignore("unused_signal")
signal player_state_changed(new_state: int, old_state: int) # Uses Player.State enum
@warning_ignore("unused_signal")
signal player_spawned(player: Node2D)
@warning_ignore("unused_signal")
signal player_died

# --- Resource Signals ---
@warning_ignore("unused_signal")
signal ram_changed(current: float, maximum: float)
@warning_ignore("unused_signal")
signal ram_critical_reached
@warning_ignore("unused_signal")
signal ram_cleared
@warning_ignore("unused_signal")
signal ram_overflow # Game Over trigger

# --- Progression Signals ---
@warning_ignore("unused_signal")
signal complexity_tier_changed(new_tier: PlayerComplexity)
@warning_ignore("unused_signal")
signal optimization_fragments_updated(current: int, required: int)
@warning_ignore("unused_signal")
signal optimization_ready

# --- World Signals ---
@warning_ignore("unused_signal")
signal wave_started(wave_number: int)
@warning_ignore("unused_signal")
signal wave_completed(wave_number: int)
@warning_ignore("unused_signal")
signal enemy_spawned(enemy: Node2D)
@warning_ignore("unused_signal")
signal status_effect_applied(effect_type: String, data: Dictionary)
@warning_ignore("unused_signal")
signal difficulty_increased(tier: int, time_elapsed: float)

# --- World & Environment ---
@warning_ignore("unused_signal")
signal sector_changed(coords: Vector2i)
@warning_ignore("unused_signal")
signal time_frozen_started(duration: float)
@warning_ignore("unused_signal")
signal time_frozen_ended

var _freeze_timer: Timer

func _ready() -> void:
	_freeze_timer = Timer.new()
	_freeze_timer.one_shot = true
	_freeze_timer.timeout.connect(_on_freeze_timeout)
	add_child(_freeze_timer)
	
	time_frozen_started.connect(_on_time_frozen_started)

func _on_time_frozen_started(duration: float) -> void:
	_freeze_timer.start(duration)

func _on_freeze_timeout() -> void:
	time_frozen_ended.emit()
