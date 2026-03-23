extends Control
class_name ComplexityMeter

## Displays progress toward next complexity tier refactor.

@onready var _progress_bar: ProgressBar = get_node_or_null("../ComplexityMeterProgress")
@onready var _percent_label: Label = get_node_or_null("../PercentLabel")

var _current: float = 0.0
var _required: float = 10.0

func _ready() -> void:
	GameEvents.optimization_fragments_updated.connect(_on_progress_updated)
	GameEvents.complexity_tier_changed.connect(_on_tier_changed)
	_update_display()

func _on_progress_updated(current: float, required: float) -> void:
	_current = current
	_required = required
	_update_display()

func _on_tier_changed(_new_tier: PlayerComplexity) -> void:
	_current = 0.0
	_update_display()

func _update_display() -> void:
	if _progress_bar:
		_progress_bar.max_value = _required
		_progress_bar.value = _current
	
	if _percent_label:
		var percent = 0.0
		if _required > 0:
			percent = (_current / _required) * 100.0
		_percent_label.text = "%d%%" % int(percent)
