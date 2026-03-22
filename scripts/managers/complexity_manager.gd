extends Node
class_name ComplexityManager

## Component responsible for managing Big O complexity tiers.
## It handles the linear progression from O(2^n) to O(1).

signal complexity_changed(new_complexity: PlayerComplexity)
signal optimization_progress_changed(current: int, required: int)
signal optimization_ready

@export_category("Configuration")
## List of complexity tiers ordered from most complex (O(2^n)) to least (O(1)).
@export var complexity_tiers: Array[PlayerComplexity] = []
## The tier the player starts at (index in the array).
@export var initial_tier_index: int = 0 # Default to O(2^n)

## Fragments required to fully optimize one tier.
@export var fragments_per_tier: int = 8

var current_index: int = 0
var current_complexity: PlayerComplexity
var current_fragments: int = 0

func _ready() -> void:
	complexity_changed.connect(_on_complexity_changed)
	optimization_progress_changed.connect(_on_optimization_progress_changed)
	optimization_ready.connect(_on_optimization_ready)
	# Initialize to the starting tier
	set_tier(initial_tier_index)

## Adds regular optimization progress (Code Fragments).
func add_optimization_fragment(amount: int = 1) -> void:
	if current_index >= complexity_tiers.size() - 1:
		return # Already at O(1)
		
	current_fragments += amount
	
	if current_fragments >= fragments_per_tier:
		current_fragments = fragments_per_tier
		optimization_ready.emit()
	
	optimization_progress_changed.emit(current_fragments, fragments_per_tier)

func can_refactor_now() -> bool:
	return current_fragments >= fragments_per_tier or current_index >= complexity_tiers.size() - 1

## Moves the player to a more efficient tier (e.g., O(n) -> O(log n)).
func refactor() -> bool:
	if current_index < complexity_tiers.size() - 1:
		set_tier(current_index + 1)
		current_fragments = 0
		optimization_progress_changed.emit(current_fragments, fragments_per_tier)
		print("Refactored! Now at: ", current_complexity.tier_name)
		return true
	else:
		print("Already at maximum efficiency: O(1)!")
		return false

## Returns the processing time for refactoring based on current complexity.
## Scaling based on implementation plan: O(2^n) = 3s, O(n^2) = 1.5s, O(n) = 0.3s, O(1) = 0s.
func get_processing_time() -> float:
	if not current_complexity:
		return 0.0
	
	match current_complexity.tier_name:
		"O(2^n)": return 3.0
		"O(n^2)": return 1.5
		"O(n log n)": return 1.0 # Intermediate tier
		"O(n)": return 0.3
		"O(log n)": return 0.1 # Intermediate tier
		"O(1)": return 0.0
		_: return 0.5

## Moves the player to a less efficient tier (e.g., O(n) -> O(n^2)).
func accumulate_debt() -> bool:
	if current_index > 0:
		set_tier(current_index - 1)
		print("Technical Debt accumulated! Now at: ", current_complexity.tier_name)
		return true
	else:
		return false

## Sets the complexity to a specific index and emits the change signal.
func set_tier(index: int) -> void:
	index = clampi(index, 0, complexity_tiers.size() - 1)
	current_index = index
	current_complexity = complexity_tiers[current_index]
	
	complexity_changed.emit(current_complexity)

func get_current_complexity() -> PlayerComplexity:
	return current_complexity

func _on_complexity_changed(new_complexity: PlayerComplexity) -> void:
	GameEvents.complexity_tier_changed.emit(new_complexity)

func _on_optimization_progress_changed(current: int, required: int) -> void:
	GameEvents.optimization_fragments_updated.emit(current, required)

func _on_optimization_ready() -> void:
	GameEvents.optimization_ready.emit()
