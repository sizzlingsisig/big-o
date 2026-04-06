extends CanvasLayer

signal restart_requested

@onready var boot_container: Control = $BootContainer
@onready var loading_label: Label = $BootContainer/LoadingLabel
@onready var loading_bar: ProgressBar = $BootContainer/LoadingBar
@onready var desktop_container: Control = $DesktopContainer
@onready var xp_wallpaper: TextureRect = $DesktopContainer/XPWallpaper
@onready var victory_overlay: Control = $DesktopContainer/VictoryOverlay
@onready var victory_title: Label = $DesktopContainer/VictoryOverlay/VictoryTitle
@onready var stats_container: VBoxContainer = $DesktopContainer/VictoryOverlay/StatsContainer
@onready var restart_hint: Label = $DesktopContainer/VictoryOverlay/RestartHint
@onready var scanlines: ColorRect = $Scanlines

var _final_loc: int = 0
var _final_time_survived: float = 0.0

const SOUND_STARTUP: AudioStream = preload("res://assets/WinXp/Sounds/Windows XP Startup.wav")

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("victory_screen")
	
	# Keep game paused during victory sequence
	
	# Start boot sequence
	print("[Victory] _ready called, starting boot sequence")
	_start_boot_sequence()

func start_victory_sequence(loc_processed: int, time_survived: float) -> void:
	_final_loc = loc_processed
	_final_time_survived = time_survived
	# Delay before starting boot sequence (let player see O(1) first)
	await get_tree().create_timer(1.0).timeout
	_start_boot_sequence()

func _start_boot_sequence() -> void:
	print("[Victory] _start_boot_sequence called")
	visible = true
	
	# Hide desktop initially
	desktop_container.visible = false
	victory_overlay.visible = false
	
	# Setup scanlines
	scanlines.visible = true
	scanlines.modulate.a = 0.0
	
	# Phase 1: Flash effect
	if has_node("/root/ScreenFX"):
		var screen_fx = get_node("/root/ScreenFX")
		if screen_fx and screen_fx.has_method("flash"):
			screen_fx.flash(Color.WHITE, 0.3)
	
	# Phase 2: Show boot text quickly
	await get_tree().create_timer(0.3).timeout
	boot_container.visible = true
	loading_label.text = "INITIALIZING KERNEL..."
	
	# Phase 3: Fast loading bar (1s)
	await get_tree().create_timer(0.2).timeout
	_animate_loading_bar()
	await get_tree().create_timer(1.0).timeout
	
	# Phase 4: Directly show desktop (no fade)
	_fade_to_desktop()

func _animate_loading_bar() -> void:
	var tween = create_tween()
	tween.tween_property(loading_bar, "value", 100.0, 1.2)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func _fade_to_desktop() -> void:
	# Hide boot screen immediately
	boot_container.visible = false
	
	# Show desktop directly (no fade)
	desktop_container.visible = true
	desktop_container.modulate.a = 1.0
	
	# Play startup sound
	_play_startup_sound()
	
	# Immediately show victory overlay
	_show_victory()

func _play_startup_sound() -> void:
	if SOUND_STARTUP:
		var audio = AudioStreamPlayer.new()
		audio.stream = SOUND_STARTUP
		audio.bus = "Master"
		add_child(audio)
		audio.play()
		await audio.finished
		audio.queue_free()

func _show_victory() -> void:
	victory_overlay.visible = true
	victory_overlay.modulate.a = 0.0
	
	# Update stats
	_update_stats()
	
	# Fade in victory text
	var tween = create_tween()
	tween.tween_property(victory_overlay, "modulate:a", 1.0, 0.5)
	
	# Fade out scanlines
	var scan_tween = create_tween()
	scan_tween.tween_property(scanlines, "modulate:a", 0.0, 1.0)
	await scan_tween.finished
	scanlines.visible = false
	
	# Start pulse on restart hint
	_pulse_restart_hint()

func _update_stats() -> void:
	if stats_container:
		var time_label = stats_container.get_node_or_null("TimeLabel")
		if time_label:
			var minutes = int(_final_time_survived) / 60
			var seconds = int(_final_time_survived) % 60
			time_label.text = "TIME: %d:%02d" % [minutes, seconds]
		
		# Also update LOC if we have it
		if _final_loc > 0:
			var loc_label = stats_container.get_node_or_null("LOCLabel")
			if loc_label:
				loc_label.text = "LOC: %d" % _final_loc

func _pulse_restart_hint() -> void:
	while is_instance_valid(self) and victory_overlay.visible:
		if restart_hint:
			var tween = create_tween()
			tween.tween_property(restart_hint, "modulate:a", 0.3, 0.5)
			tween.tween_property(restart_hint, "modulate:a", 1.0, 0.5)
			await tween.finished
			await get_tree().create_timer(randf_range(1.5, 2.5)).timeout

func show_victory(loc_processed: int, time_survived: float) -> void:
	_final_loc = loc_processed
	_final_time_survived = time_survived

func _get_stats_from_tree() -> void:
	# Try to get stats from world if not already set
	if _final_time_survived <= 0:
		var world = get_tree().get_first_node_in_group("world")
		if world:
			var spawner = world.get_node_or_null("EnemySpawner")
			if spawner and spawner.has_method("get_elapsed_time"):
				_final_time_survived = spawner.get_elapsed_time()
	
	if _final_loc <= 0:
		var progression = get_tree().get_first_node_in_group("progression_manager")
		if progression and progression.has_method("get_total_loc"):
			_final_loc = progression.get_total_loc()

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
	visible = false
	get_tree().paused = false
	GameEvents.restart_requested.emit()
	GameEvents.game_state_requested.emit(BigOConstants.STATE_PLAY)

func _return_to_menu() -> void:
	visible = false
	get_tree().paused = false
	GameEvents.game_state_requested.emit(BigOConstants.STATE_MENU)
