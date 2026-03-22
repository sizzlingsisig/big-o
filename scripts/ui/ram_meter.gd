extends Node
class_name RAMMeter

signal ram_changed(current: float, maximum: float)
signal ram_full
signal ram_cleared
signal ram_overflow

@export var max_ram: float = 100.0
@export var critical_threshold: float = 70.0

var current_ram: float = 0.0

var _is_critical: bool = false

func _ready() -> void:
	add_to_group("ram_meter")

func _process(_delta: float) -> void:
	pass

func add_ram(amount: float) -> void:
	current_ram = minf(max_ram, current_ram + amount)
	emit_signal("ram_changed", current_ram, max_ram)
	
	if current_ram >= critical_threshold and not _is_critical:
		_is_critical = true
		emit_signal("ram_full")
	
	if current_ram >= max_ram:
		_trigger_overflow()

func clear_ram(amount: float = max_ram) -> void:
	current_ram = maxf(0, current_ram - amount)
	emit_signal("ram_changed", current_ram, max_ram)
	emit_signal("ram_cleared")
	_is_critical = false

func get_ram_ratio() -> float:
	if max_ram <= 0:
		return 0.0
	return current_ram / max_ram

func is_critical() -> bool:
	return _is_critical

func _trigger_overflow() -> void:
	print("RAM OVERFLOW! System crash imminent...")
	ram_overflow.emit()
	current_ram = max_ram
