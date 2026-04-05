extends Control
class_name MainMenu

@onready var start_button: Button = $CenterContainer/ContentVBox/ActionsSection/StartButton
@onready var quit_button: Button = $CenterContainer/ContentVBox/ActionsSection/QuitButton
@onready var title_label: Label = $CenterContainer/ContentVBox/BrandingSection/Title
@onready var glitch_labels_container: Control = $BackgroundLayer/GlitchLabels

var _original_title_text: String = "BIG O"
var _glitch_timer: float = 0.0
var _glitch_interval: float = 3.0
var _is_glitching: bool = false
var _breath_timer: float = 0.0
var _occupied_areas: Dictionary = {}

@onready var _font = preload("res://assets/fonts/ByteBounce.ttf")

func _ready() -> void:
	start_button.pivot_offset = start_button.size / 2.0
	quit_button.pivot_offset = quit_button.size / 2.0
	
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	start_button.mouse_entered.connect(func(): _on_button_hover(start_button, true))
	quit_button.mouse_entered.connect(func(): _on_button_hover(quit_button, true))
	start_button.mouse_exited.connect(func(): _on_button_hover(start_button, false))
	quit_button.mouse_exited.connect(func(): _on_button_hover(quit_button, false))
	
	start_button.grab_focus()

func _process(delta: float) -> void:
	_update_title_glitch(delta)
	_update_title_breath(delta)
	_update_glitch_labels(delta)

func _update_title_glitch(delta: float) -> void:
	_glitch_timer += delta
	
	if _glitch_timer >= _glitch_interval:
		_glitch_timer = 0.0
		_glitch_interval = randf_range(2.0, 5.0)
		
		if randf() < 0.4:
			_trigger_text_glitch()
	
	if _is_glitching and randf() < 0.1:
		title_label.position.x = randf_range(-2.0, 2.0)
		title_label.position.y = randf_range(-1.0, 1.0)
	else:
		title_label.position = Vector2.ZERO

func _trigger_text_glitch() -> void:
	_is_glitching = true
	var glitch_text = BigOConstants.DEBT_LOGS.pick_random()
	title_label.text = glitch_text
	
	var tween = create_tween()
	tween.tween_interval(0.15)
	tween.tween_callback(func():
		title_label.text = _original_title_text
		_is_glitching = false
	)

func _update_title_breath(delta: float) -> void:
	_breath_timer += delta
	var scale_factor = 1.0 + sin(_breath_timer * 1.5) * 0.015
	title_label.scale = Vector2(scale_factor, scale_factor)

func _update_glitch_labels(delta: float) -> void:
	var camera = get_viewport().get_camera_2d()
	var spawn_origin = Vector2.ZERO
	var viewport_size = get_viewport_rect().size
	
	if camera:
		spawn_origin = camera.get_screen_center_position() - (viewport_size / 2.0)
	
	if randf() < 0.01:
		_spawn_glitch_label(spawn_origin, viewport_size)
	
	for child in glitch_labels_container.get_children():
		if not child is Label or not _occupied_areas.has(child):
			continue
		
		if randf() < 0.005:
			child.position = _occupied_areas[child].position + Vector2(randf_range(-3.0, 3.0), randf_range(-2.0, 2.0))
			child.modulate.a = randf_range(0.1, 0.25)
		else:
			child.position = _occupied_areas[child].position
			child.modulate.a = move_toward(child.modulate.a, 0.15, 0.002)

func _spawn_glitch_label(spawn_origin: Vector2, viewport_size: Vector2) -> void:
	var text = BigOConstants.DEBT_LOGS.pick_random()
	var font_size = randi_range(24, 36)
	var label = Label.new()
	label.text = text
	label.add_theme_font_override("font", _font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0, 0.8, 0.3, 0.2))
	label.modulate.a = 0.0
	
	var text_size = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var pos = spawn_origin + Vector2(
		randf_range(50, viewport_size.x - text_size.x - 50),
		randf_range(50, viewport_size.y - text_size.y - 50)
	)
	label.position = pos
	glitch_labels_container.add_child(label)
	_occupied_areas[label] = Rect2(pos, text_size)
	
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", randf_range(0.15, 0.25), randf_range(1.0, 2.0))
	tween.tween_interval(randf_range(3.0, 5.0))
	tween.tween_property(label, "modulate:a", 0.0, randf_range(1.0, 2.0))
	tween.tween_callback(func():
		_occupied_areas.erase(label)
		label.queue_free()
	)

func _on_start_pressed() -> void:
	GameEvents.start_requested.emit()

func _on_quit_pressed() -> void:
	GameEvents.quit_requested.emit()

func _on_button_hover(button: Button, hovering: bool) -> void:
	var target_scale = Vector2(1.05, 1.05) if hovering else Vector2(1.0, 1.0)
	
	button.pivot_offset = button.size / 2.0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(button, "scale", target_scale, 0.1)

func _on_button_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var button = start_button if start_button.has_focus() else quit_button
		button.pivot_offset = button.size / 2.0
		
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.05)
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
