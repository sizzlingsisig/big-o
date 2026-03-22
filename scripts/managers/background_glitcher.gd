extends Control

## Makes background labels jitter and change their text/visibility to simulate glitches.

@export var glitch_chance: float = 0.02 # Lowered
@export var jitter_intensity: float = 2.0 # Lowered
@export var spawn_interval: float = 3.0 # Much slower
@export var label_margin: float = 40.0 # Space between labels

var _occupied_areas: Dictionary = {} # Label -> Rect2
var _timer: float = 0.0

@onready var font = preload("res://assets/fonts/ByteBounce.ttf")

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var camera = get_viewport().get_camera_2d()
	var corruption_factor = 1.0
	
	if camera:
		var dist = camera.get_screen_center_position().length()
		# Scale from 1.0 (at origin) to 4.0 (at 15,000 units)
		corruption_factor = clamp(1.0 + (dist / 5000.0), 1.0, 4.0)

	_timer += delta * corruption_factor # Spawn faster the further we go
	
	if _timer >= spawn_interval:
		_timer = 0.0
		# Occasionally spawn a text error, or a binary block
		if randf() < 0.4:
			_spawn_random_label()
		else:
			_spawn_binary_block()

	for child in get_children():
		if not child is Label or not _occupied_areas.has(child): continue
		
		var base_pos = _occupied_areas[child].position
		
		# Occasional Glitch - chance increases with distance
		if randf() < glitch_chance * corruption_factor:
			child.position = base_pos + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * jitter_intensity * corruption_factor
			child.modulate.a = randf_range(0.1, 0.3)
			
			# Change text occasionally
			if randf() < 0.1:
				child.text = BigOConstants.DEBT_LOGS.pick_random()
		else:
			# Return to base position and faintness
			child.position = base_pos
			child.modulate.a = move_toward(child.modulate.a, 0.15, 0.01)

func _spawn_random_label() -> void:
	var text = BigOConstants.DEBT_LOGS.pick_random()
	var font_size = randi_range(48, 72)
	var label = _create_valid_label(text, font_size)
	if label:
		_animate_label(label)

func _spawn_binary_block() -> void:
	var rows = randi_range(3, 6)
	var cols = randi_range(4, 10)
	var block_text = ""
	for r in range(rows):
		for c in range(cols):
			block_text += "1" if randf() > 0.5 else "0"
		block_text += "\n"
	
	var label = _create_valid_label(block_text, randi_range(32, 40))
	if label:
		_animate_label(label)

func _create_valid_label(text: String, font_size: int) -> Label:
	var camera = get_viewport().get_camera_2d()
	var spawn_origin = Vector2.ZERO
	var viewport_size = get_viewport_rect().size
	
	if camera:
		spawn_origin = camera.get_screen_center_position() - (viewport_size / 2.0)
	
	# Calculate approximate size
	var lines = text.split("\n")
	var longest_line = ""
	for l in lines: if l.length() > longest_line.length(): longest_line = l
	
	var text_size = font.get_string_size(longest_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	text_size.y = font_size * lines.size()
	
	# Try finding a free spot around the camera view
	for attempt in range(15):
		var pos = spawn_origin + Vector2(
			randf_range(50, viewport_size.x - text_size.x - 50),
			randf_range(50, viewport_size.y - text_size.y - 50)
		)
		
		var rect = Rect2(pos, text_size).grow(label_margin)
		
		var overlapped = false
		for other_rect in _occupied_areas.values():
			if rect.intersects(other_rect):
				overlapped = true
				break
		
		if not overlapped:
			var label = Label.new()
			label.text = text
			label.add_theme_font_override("font", font)
			label.add_theme_font_size_override("font_size", font_size)
			label.add_theme_color_override("font_color", Color(0, 1, 0.5, 1))
			label.modulate.a = 0.0
			label.position = pos
			add_child(label)
			_occupied_areas[label] = rect
			return label
			
	return null # Failed to find space

func _animate_label(label: Label) -> void:
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", randf_range(0.15, 0.25), 2.0)
	tween.tween_interval(4.0)
	tween.tween_property(label, "modulate:a", 0.0, 3.0)
	tween.tween_callback(func():
		_occupied_areas.erase(label)
		label.queue_free()
	)
