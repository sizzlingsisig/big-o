extends CanvasLayer

signal restart_requested

@onready var error_code: Label = $Container/ErrorCode
@onready var error_message: Label = $Container/ErrorMessage
@onready var technical_debt_label: Label = $Container/TechnicalDebtLabel
@onready var ram_usage_label: Label = $Container/RAMUsageLabel
@onready var time_survived_label: Label = $Container/TimeSurvivedLabel
@onready var restart_hint: Label = $Container/RestartHint
@onready var container: Control = $Container
@onready var bsod_sprite: TextureRect = $BsodSprite
@onready var glitch_overlay: Control = $GlitchOverlay

var _crash_reason: String = "HEAP_OVERFLOW"
var _final_ram: float = 100.0
var _final_time_survived: float = 0.0
var _is_glitching: bool = false

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_add_glitch_timer()

func show_game_over(ram_percentage: float, time_survived: float, reason: String = "HEAP_OVERFLOW") -> void:
	_final_ram = ram_percentage
	_final_time_survived = time_survived
	_crash_reason = reason
	
	var crash_codes: Array[String] = [
		"0x0000000D", "0x0000000C", "0x0000000A", "0x00000007",
		"0xDEADBEEF", "0xC000021A", "0x00000050", "0x0000001E"
	]
	var crash_messages: Array[String] = [
		"FATAL_EXCEPTION_IN_SYSTEM",
		"STACK_BUFFER_OVERRUN",
		"IRQL_NOT_LESS_OR_EQUAL",
		"POOL_CORRUPTION_DETECTED",
		"MEMORY_CORRUPTION_CRITICAL",
		"SESSION_CRITICAL_OBJECT_DIED",
		"PFN_LIST_CORRUPT",
		"KMODE_EXCEPTION_NOT_HANDLED"
	]
	
	var index = randi() % crash_codes.size()
	var code = crash_codes[index] if _crash_reason == "HEAP_OVERFLOW" else _crash_reason
	
	if error_code:
		error_code.text = "A fatal exception (" + code + ") has been detected in your system."
	
	if error_message:
		error_message.text = crash_messages[index] if _crash_reason == "HEAP_OVERFLOW" else "FATAL_SYSTEM_ERROR"
	
	if technical_debt_label:
		technical_debt_label.text = "TECHNICAL DEBT: " + _crash_reason
	if ram_usage_label:
		ram_usage_label.text = "RAM USAGE: %.0f%%" % _final_ram
	if time_survived_label:
		var minutes = int(_final_time_survived) / 60
		var seconds = int(_final_time_survived) % 60
		time_survived_label.text = "TIME SURVIVED: %d:%02d" % [minutes, seconds]
	if restart_hint:
		restart_hint.text = "PRESS SPACE TO RESTART · PRESS ESC TO MENU"
	
	visible = true
	
	# Hide HUD if present
	var hud = get_parent().get_node_or_null("HUD")
	if hud:
		hud.visible = false
		
	_start_glitch_effect()

	if get_tree():
		get_tree().paused = true

func _start_glitch_effect() -> void:
	_is_glitching = true
	container.position.x = randf_range(-10, 10)
	container.position.y = randf_range(-5, 5)
	
	var tween = create_tween().set_loops(30)
	tween.tween_callback(_glitch_frame)
	tween.tween_interval(0.05)

func _glitch_frame() -> void:
	if not _is_glitching:
		return
	
	container.position.x = randf_range(-8, 8)
	container.position.y = randf_range(-4, 4)
	
	if randf() > 0.5:
		container.modulate.r = randf_range(0.8, 1.2)
		container.modulate.g = randf_range(0.8, 1.2)
		container.modulate.b = randf_range(0.8, 1.2)
	else:
		container.modulate = Color.WHITE
	
	if randf() > 0.8 and glitch_overlay:
		glitch_overlay.visible = not glitch_overlay.visible

func _stop_glitch_effect() -> void:
	_is_glitching = false
	container.position = Vector2.ZERO
	container.modulate = Color.WHITE
	if glitch_overlay:
		glitch_overlay.visible = false

func _add_glitch_timer() -> void:
	await get_tree().create_timer(0.1).timeout
	_restart_hint_pulse()

func _restart_hint_pulse() -> void:
	while is_instance_valid(self) and visible:
		if restart_hint:
			var tween = create_tween()
			tween.tween_property(restart_hint, "modulate:a", 0.3, 0.5)
			tween.tween_property(restart_hint, "modulate:a", 1.0, 0.5)
			await tween.finished
			await get_tree().create_timer(randf_range(1.0, 2.0)).timeout

func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		get_viewport().set_input_as_handled()
		_restart_to_play()
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_return_to_menu()

func _restart_to_play() -> void:
	_stop_glitch_effect()
	visible = false
	if get_tree():
		get_tree().paused = false
	GameEvents.restart_requested.emit()
	GameEvents.game_state_requested.emit(BigOConstants.STATE_PLAY)

func _return_to_menu() -> void:
	_stop_glitch_effect()
	visible = false
	if get_tree():
		get_tree().paused = false
	GameEvents.game_state_requested.emit(BigOConstants.STATE_MENU)
