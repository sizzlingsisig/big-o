extends CanvasLayer

const SectorGridScript = preload("res://scripts/globals/sector_grid.gd")

@onready var ram_progress_bar: ProgressBar = %RAMProgressBar
@onready var ram_percent_label: Label = %RAMPercentLabel
@onready var complexity_value: Label = %ComplexityValue
@onready var status_value: Label = %StatusValue
@onready var ram_warning: Label = %RAMDisruptWarning

var _player: Player
var _complexity_manager: ComplexityManager
var _current_player_state: Player.State = Player.State.IDLE
var _last_sector: Vector2i = Vector2i(-999, -999)

func _ready() -> void:
	GameEvents.ram_changed.connect(_on_ram_changed)
	GameEvents.ram_critical_reached.connect(_on_ram_full)
	GameEvents.player_state_changed.connect(_on_player_state_changed)
	GameEvents.complexity_tier_changed.connect(_on_complexity_changed)
	
	_on_ram_changed(0.0, 100.0)
	_update_status_display(Player.State.IDLE)

func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(_player):
		if not _player.state_changed.is_connected(_on_player_state_changed):
			_player.state_changed.connect(_on_player_state_changed)
		
		if not _complexity_manager and "complexity" in _player:
			_complexity_manager = _player.complexity
			if _complexity_manager:
				if not _complexity_manager.complexity_changed.is_connected(_on_complexity_changed):
					_complexity_manager.complexity_changed.connect(_on_complexity_changed)
				_update_complexity_display(_complexity_manager.get_current_complexity())

func _on_ram_changed(current: float, maximum: float) -> void:
	if ram_progress_bar:
		ram_progress_bar.value = current
		ram_progress_bar.max_value = maximum
	
	if ram_percent_label:
		var ratio = current / maximum if maximum > 0 else 0.0
		ram_percent_label.text = "%d%%" % int(ratio * 100)
		
		# Pulse red if RAM is critical (above 70%)
		if ratio >= 0.7:
			ram_percent_label.modulate = Color(1.0, 0.3, 0.3)
			if Engine.get_frames_drawn() % 30 < 15:
				ram_percent_label.modulate.a = 0.5
			else:
				ram_percent_label.modulate.a = 1.0
		else:
			ram_percent_label.modulate = Color(1, 0.4, 1, 1) # Original magenta-ish

func _on_player_state_changed(new_state: Player.State, _old_state: Player.State) -> void:
	_current_player_state = new_state
	_update_status_display(new_state)

func _update_status_display(state: Player.State) -> void:
	if not status_value:
		return
	
	var old_text = status_value.text
	
	match state:
		Player.State.IDLE:
			status_value.text = "READY"
		Player.State.PROCESSING:
			status_value.text = "RUNNING"
		Player.State.DISRUPTED:
			status_value.text = "WAITING"
		Player.State.ERROR:
			status_value.text = "ERROR"
		Player.State.FORKING:
			status_value.text = "RUNNING"
		Player.State.DEAD:
			status_value.text = "HALTED"
	
	if old_text != status_value.text:
		_react_label_change(status_value)
	
	status_value.modulate = Color.WHITE

func _react_label_change(label: Label) -> void:
	var tween = create_tween().set_parallel(true)
	label.pivot_offset = label.size / 2
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(label, "modulate", Color(0, 1, 0.5), 0.1) # Flash green
	
	tween.chain().set_parallel(true)
	tween.tween_property(label, "scale", Vector2.ONE, 0.2)
	tween.tween_property(label, "modulate", Color.WHITE, 0.2)

func _on_complexity_changed(new_data: PlayerComplexity) -> void:
	_update_complexity_display(new_data)
	if complexity_value:
		_react_label_change(complexity_value)

func _update_complexity_display(data: PlayerComplexity) -> void:
	if not data:
		return
	if complexity_value:
		complexity_value.text = data.tier_name
		complexity_value.modulate = Color.WHITE

func _on_ram_full() -> void:
	if ram_warning:
		ram_warning.visible = true
		_react_label_change(ram_warning) # Pulse the warning
		
		var tween = create_tween()
		tween.tween_interval(2.0)
		tween.tween_callback(_hide_ram_warning)

func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_2d()
	if camera:
		var pos = camera.get_screen_center_position()
		var current_sector: Vector2i = SectorGridScript.get_sector_at_position(pos)
		if current_sector != _last_sector:
			_last_sector = current_sector
			GameEvents.sector_changed.emit(current_sector)
	
	_update_glitch_effects()

func _update_glitch_effects() -> void:
	var is_disrupted = _current_player_state == Player.State.DISRUPTED
	var is_error = _current_player_state == Player.State.ERROR
	
	if is_disrupted or is_error:
		# Glitch the status label colors
		if status_value and Engine.get_frames_drawn() % 5 == 0:
			status_value.modulate = Color(randf(), randf(), randf(), 0.8)
	else:
		# Position is handled by HBox, but ensure modulate is reset
		if status_value:
			status_value.modulate = Color.WHITE

func _hide_ram_warning() -> void:
	if ram_warning:
		ram_warning.visible = false
