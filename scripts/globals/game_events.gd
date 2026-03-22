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

# --- World & Environment ---
@warning_ignore("unused_signal")
signal sector_changed(coords: Vector2i)
