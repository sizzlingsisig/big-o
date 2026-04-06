extends Node
class_name ComplexityManager

## Component responsible for managing Big O complexity tiers.
## It handles the linear progression from O(2^n) to O(1).

signal complexity_changed(new_complexity: PlayerComplexity)
signal optimization_progress_changed(current: float, required: float)
signal optimization_ready
signal processing_started
signal processing_completed
signal processing_interrupted
signal optimization_complete

@export_category("Configuration")
## List of complexity tiers ordered from most complex (O(2^n)) to least (O(1)).
@export var complexity_tiers: Array[PlayerComplexity] = []
## The tier the player starts at (index in the array).
@export var initial_tier_index: int = 0

## Fragments required per tier (simpler scaling)
@export var fragments_per_tier: Array[int] = [10, 15, 20, 25, 30]

## Hover time for power-ups (in seconds per tier)
@export var hover_times: Array[float] = [2.0, 1.8, 1.5, 1.2, 1.0]

var current_index: int = 0
var current_complexity: PlayerComplexity
var current_fragments: float = 0.0
var is_processing: bool = false

func get_required_fragments() -> int:
	if current_index >= fragments_per_tier.size():
		return 1
	return fragments_per_tier[current_index]

func get_hover_time() -> float:
	if current_index >= hover_times.size():
		return 1.0
	return hover_times[current_index]

func _ready() -> void:
	complexity_changed.connect(_on_complexity_changed)
	optimization_progress_changed.connect(_on_optimization_progress_changed)
	optimization_ready.connect(_on_optimization_ready)
	set_tier(initial_tier_index)

## Adds optimization progress. When full, triggers refactor automatically.
func add_optimization_fragment(amount: float = 1.0) -> void:
	if current_index >= complexity_tiers.size() - 1:
		return
		
	current_fragments += amount
	
	var required = float(get_required_fragments())
	if current_fragments >= required:
		current_fragments = required
		if not is_processing:
			optimization_ready.emit()
	
	optimization_progress_changed.emit(current_fragments, required)

func can_refactor_now() -> bool:
	return current_fragments >= float(get_required_fragments()) or current_index >= complexity_tiers.size() - 1

## Moves the player to a more efficient tier (e.g., O(n) -> O(log n)).
func refactor() -> bool:
	print("[ComplexityManager] refactor() called, current_index: ", current_index, ", size: ", complexity_tiers.size())
	if current_index >= complexity_tiers.size() - 1:
		# Already at O(1) - emit victory signal
		print("[ComplexityManager] At O(1)! Emitting victory signal")
		if not is_processing:
			is_processing = true
			processing_started.emit()
			# Delay the victory to allow processing animation to play
			await get_tree().create_timer(0.5).timeout
			optimization_complete.emit()
			print("[ComplexityManager] optimization_complete emitted!")
		return false
		
	if current_index < complexity_tiers.size() - 1:
		is_processing = true
		processing_started.emit()
		print("Processing started. Time: ", get_processing_time(), "s")
		return true
	
	return false

## Called by player when processing timer completes
func complete_refactor() -> void:
	var was_at_max_before = current_index >= complexity_tiers.size() - 1
	
	set_tier(current_index + 1)
	current_fragments = 0.0
	optimization_progress_changed.emit(0.0, float(get_required_fragments()))
	print("Refactored! Now at: ", current_complexity.tier_name)
	is_processing = false
	processing_completed.emit()
	
	# Check if we just reached O(1) - trigger victory!
	if not was_at_max_before and current_index >= complexity_tiers.size() - 1:
		print("[ComplexityManager] Reached O(1)! Emitting victory!")
		optimization_complete.emit()

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

## Debug function to trigger victory when at max tier
func trigger_victory() -> void:
	print("[ComplexityManager] trigger_victory called!")
	optimization_complete.emit()
	print("[ComplexityManager] optimization_complete emitted!")

func restore_progress_to_80_percent() -> void:
	if is_processing:
		is_processing = false
		processing_interrupted.emit()
	
	var required = float(get_required_fragments())
	current_fragments = required * 0.8
	optimization_progress_changed.emit(current_fragments, required)

func _on_complexity_changed(new_complexity: PlayerComplexity) -> void:
	GameEvents.complexity_tier_changed.emit(new_complexity)

func _on_optimization_progress_changed(current: float, required: float) -> void:
	GameEvents.optimization_fragments_updated.emit(current, required)

func _on_optimization_ready() -> void:
	GameEvents.optimization_ready.emit()
	# Auto-refactor when meter is full
	refactor()
