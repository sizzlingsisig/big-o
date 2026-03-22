extends Node

## Tracks project progression (LOC) and manages "Feature Creep" milestones.

signal loc_changed(new_total: int)
signal milestone_reached(milestone_index: int)

@export var milestone_interval: int = BigOConstants.MILESTONE_INTERVAL # LOC between color shifts

var total_loc: int = 0
var current_milestone: int = 0

func _ready() -> void:
	add_to_group("progression_manager")

func add_loc(amount: int) -> void:
	total_loc += amount
	loc_changed.emit(total_loc)
	
	# Check for color shift milestone
	var new_milestone = floor(total_loc / float(milestone_interval))
	if new_milestone > current_milestone:
		current_milestone = int(new_milestone)
		milestone_reached.emit(current_milestone)
		print("Milestone Reached: ", current_milestone)

## Returns a 0.0 to 1.0 value representing the current "Corruption" or project scale.
func get_corruption_level() -> float:
	# Scales from 0.0 to 1.0 based on reaching 2000 LOC
	return clamp(total_loc / 2000.0, 0.0, 1.0)

# DEBUG: Manual progression for testing
func _input(event: InputEvent) -> void:
	if OS.is_debug_build() and event.is_action_pressed("ui_page_up"):
		add_loc(100)
		print("Debug: LOC +100 (Total: ", total_loc, ")")
