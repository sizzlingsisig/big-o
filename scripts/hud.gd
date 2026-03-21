extends CanvasLayer

## Handles the display of the system's memory address based on player position.

@onready var address_label: Label = %AddressLabel

func _ready() -> void:
	var sector_manager = get_tree().get_first_node_in_group("sector_manager")
	if not sector_manager:
		sector_manager = get_parent().get_node_or_null("SectorManager")
	
	if sector_manager:
		sector_manager.sector_changed.connect(_on_sector_changed)

func _on_sector_changed(coords: Vector2i) -> void:
	# Create a temporary sector alert
	var alert = Label.new()
	alert.text = "MEM_BLOCK [" + str(coords.x) + ":" + str(coords.y) + "] LOADED"
	alert.add_theme_font_override("font", preload("res://ByteBounce.ttf"))
	alert.add_theme_font_size_override("font_size", 40)
	alert.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	
	# Center it
	alert.anchors_preset = Control.PRESET_CENTER
	alert.grow_horizontal = Control.GROW_DIRECTION_BOTH
	alert.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	$Control.add_child(alert)
	alert.modulate.a = 0
	
	var tween = create_tween()
	tween.tween_property(alert, "modulate:a", 1.0, 0.5)
	tween.tween_interval(1.5)
	tween.tween_property(alert, "modulate:a", 0.0, 1.0)
	tween.tween_callback(alert.queue_free)

func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_2d()
	if camera:
		var pos = camera.get_screen_center_position()
		
		# Format as Hex (padding to 4 digits)
		# We use abs() to keep it looking like memory offsets, 
		# but you could also show negative space if preferred.
		var hex_x = "%04X" % int(abs(pos.x))
		var hex_y = "%04X" % int(abs(pos.y))
		
		address_label.text = "0x" + hex_x + " : 0x" + hex_y
