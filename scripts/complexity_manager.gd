extends Node
class_name ComplexityManager

## Component responsible for managing Big O complexity tiers.
## It handles the linear progression from O(2^n) to O(1).

signal complexity_changed(new_complexity: PlayerComplexity)

@export_category("Configuration")
## List of complexity tiers ordered from most complex (O(2^n)) to least (O(1)).
@export var complexity_tiers: Array[PlayerComplexity] = []
## The tier the player starts at (index in the array).
@export var initial_tier_index: int = 0 # Default to O(2^n)

var current_index: int = 0
var current_complexity: PlayerComplexity

func _ready() -> void:
	# Initialize to the starting tier
	set_tier(initial_tier_index)

## Moves the player to a more efficient tier (e.g., O(n) -> O(log n)).
func refactor() -> bool:
	if current_index < complexity_tiers.size() - 1:
		set_tier(current_index + 1)
		print("Refactored! Now at: ", current_complexity.tier_name)
		return true
	else:
		print("Already at maximum efficiency: O(1)!")
		return false

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
