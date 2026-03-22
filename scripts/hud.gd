extends CanvasLayer

@onready var address_label: Label = %AddressLabel
@onready var ram_label: Label = %RAMLabel
@onready var ram_progress: ProgressBar = %ProgressBar
@onready var ram_warning: Label = %RAMDisruptWarning

var _ram_meter: Node

func _ready() -> void:
	_ram_meter = get_node_or_null("Control/RAMMeter")
	if not _ram_meter:
		_ram_meter = get_tree().get_first_node_in_group("ram_meter")
	
	var sector_manager = get_tree().get_first_node_in_group("sector_manager")
	if not sector_manager:
		sector_manager = get_parent().get_node_or_null("SectorManager")
	
	if sector_manager:
		sector_manager.sector_changed.connect(_on_sector_changed)
	
	if _ram_meter:
		_ram_meter.ram_changed.connect(_on_ram_changed)
		_ram_meter.ram_full.connect(_on_ram_full)

func _on_sector_changed(coords: Vector2i) -> void:
	var alert = Label.new()
	alert.text = "MEM_BLOCK [" + str(coords.x) + ":" + str(coords.y) + "] LOADED"
	alert.add_theme_font_override("font", preload("res://assets/fonts/ByteBounce.ttf"))
	alert.add_theme_font_size_override("font_size", 40)
	alert.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	
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
		
		var hex_x = "%04X" % int(abs(pos.x))
		var hex_y = "%04X" % int(abs(pos.y))
		
		address_label.text = "0x" + hex_x + " : 0x" + hex_y

func _on_ram_changed(current: float, maximum: float) -> void:
	if ram_label:
		ram_label.text = "RAM: %d%%" % int((current / maximum) * 100)
	if ram_progress:
		ram_progress.value = (current / maximum) * 100

func _on_ram_full() -> void:
	if ram_warning:
		ram_warning.visible = true
		
		var tween = create_tween()
		tween.tween_interval(2.0)
		tween.tween_callback(_hide_ram_warning)

func _hide_ram_warning() -> void:
	if ram_warning:
		ram_warning.visible = false
