extends Node
class_name SystemResourcesComponent

## Component responsible for managing system resources like RAM (health).
## Emits signals via GameEvents for decoupling.

@export var max_ram: float = 100.0
@export var critical_threshold: float = 70.0

var current_ram: float = 0.0:
	set(value):
		current_ram = clampf(value, 0.0, max_ram)
		GameEvents.ram_changed.emit(current_ram, max_ram)
		
		if current_ram >= max_ram:
			GameEvents.ram_overflow.emit()
		elif current_ram >= critical_threshold:
			GameEvents.ram_critical_reached.emit()

func _ready() -> void:
	# Initial emit
	current_ram = 0.0

func add_ram(amount: float) -> void:
	current_ram += amount

func clear_ram(amount: float) -> void:
	current_ram -= amount
	GameEvents.ram_cleared.emit()

func reset() -> void:
	current_ram = 0.0
