class_name BigOConstants

## Centralized system constants and definitions for "Big O: Technical Debt".

# --- Game State Identifiers ---
## Used for game_state_changed and game_state_requested signals
## Access via: BigOConstants.STATE_MENU, BigOConstants.STATE_PLAY, BigOConstants.STATE_GAME_OVER, BigOConstants.STATE_VICTORY
const STATE_MENU: String = "menu"
const STATE_PLAY: String = "play"
const STATE_GAME_OVER: String = "game_over"
const STATE_VICTORY: String = "victory"

## State transition map:
## menu -> play (via start_requested)
## play -> game_over (via player_death or ram_overflow)
## game_over -> menu (via menu_return)
## game_over -> play (via restart_requested)

# --- World & Grid ---
const SECTOR_SIZE: float = 2000.0

# --- Colors (Thematic Tiers) ---
const COLOR_ALPHA = Color(0.04, 0.12, 0.06) # Dark Green
const COLOR_BETA  = Color(0.04, 0.06, 0.15) # Deep Blue
const COLOR_PROD  = Color(0.12, 0.04, 0.12) # Dark Purple
const COLOR_CRASH = Color(0.15, 0.04, 0.04) # Dark Red

static func get_theme_colors() -> Array[Color]:
	return [COLOR_ALPHA, COLOR_BETA, COLOR_PROD, COLOR_CRASH]

# --- Technical Debt Strings ---
const DEBT_LOGS = [
	"SEGFAULT", 
	"NULL_PTR", 
	"MEM_LEAK", 
	"STACK_OVR", 
	"RACE_COND", 
	"JIT_ERR", 
	"CORE_DUMP", 
	"OOM_KILL", 
	"HEEP_OVERFLOW", 
	"KERNEL_PANIC"
]

# --- Gameplay ---
const MILESTONE_INTERVAL: int = 1000 # LOC between color shifts
const RAM_DUMP_AMOUNT: float = 0.2    # 20% relief on fork
const BASE_FRICTION: float = 100.0

# --- Physics Layers (2D) ---
const PHYSICS_LAYER_PLAYER: int = 1 << 0
const PHYSICS_LAYER_ENEMY: int = 1 << 1
const PHYSICS_LAYER_COLLECTIBLE: int = 1 << 2

const PHYSICS_MASK_PLAYER: int = PHYSICS_LAYER_ENEMY | PHYSICS_LAYER_COLLECTIBLE
const PHYSICS_MASK_ENEMY: int = PHYSICS_LAYER_PLAYER
const PHYSICS_MASK_COLLECTIBLE: int = PHYSICS_LAYER_PLAYER
