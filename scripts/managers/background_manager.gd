extends CanvasLayer

const SectorGridScript = preload("res://scripts/globals/sector_grid.gd")

## Synchronizes the background shader and labels with the active camera.

@onready var shader_rect: ColorRect = $ShaderRect
@onready var labels_control: Control = $Labels

var _progression_manager: Node = null
var _current_zone: int = 0

func _ready() -> void:
	GameEvents.sector_changed.connect(_on_sector_changed)
	_progression_manager = get_tree().get_first_node_in_group("progression_manager")
	
	# Initial zone setup
	var camera = get_viewport().get_camera_2d()
	if camera:
		_on_sector_changed(SectorGridScript.get_sector_at_position(camera.get_screen_center_position()))
	
	if _progression_manager:
		_progression_manager.milestone_reached.connect(_on_milestone_reached)
		print("BackgroundManager: Connected to ProgressionManager")
	else:
		# Fallback: Wait one frame in case of initialization order issues, then try again
		await get_tree().process_frame
		_progression_manager = get_tree().get_first_node_in_group("progression_manager")
		if _progression_manager:
			_progression_manager.milestone_reached.connect(_on_milestone_reached)
			print("BackgroundManager: Connected to ProgressionManager (delayed)")
		else:
			push_warning("BackgroundManager: ProgressionManager group not found.")

func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_2d()
	if camera:
		var camera_pos = camera.get_screen_center_position()
		var screen_size = get_viewport().get_visible_rect().size
		var top_left = camera_pos - (screen_size / 2.0)
		
		# Pass world offset to shader
		shader_rect.material.set_shader_parameter("world_offset", top_left)
		
		# Increase shader jitter based on distance
		var dist = camera_pos.length()
		var jitter = clamp(0.0005 + (dist / 100000.0), 0.0005, 0.005)
		shader_rect.material.set_shader_parameter("jitter_intensity", jitter)
		
		# Move the labels container inversely so children appear "locked" in world space
		# while the CanvasLayer keeps them centered on screen.
		labels_control.position = -top_left

func _on_milestone_reached(index: int) -> void:
	# Cycle through colors based on milestone
	var colors = BigOConstants.get_theme_colors()
	var color_index = index % colors.size()
	var target_color = colors[color_index]
	
	print("Background color shifting to: ", target_color)
	
	var current_param = shader_rect.material.get_shader_parameter("base_color")
	var current_color: Color
	
	# Handle both Color and Vector3 return types from shader params
	if current_param is Vector3:
		current_color = Color(current_param.x, current_param.y, current_param.z)
	else:
		current_color = current_param
	
	var tween = create_tween()
	tween.tween_method(func(c: Color): 
		shader_rect.material.set_shader_parameter("base_color", c), 
		current_color, 
		target_color, 4.0) # Slower fade for progression

func _on_sector_changed(coords: Vector2i) -> void:
	# Change zone every 3 sectors (Euclidean distance from origin as a simple zone metric)
	var distance_in_sectors = int(coords.length())
	var new_zone = int(distance_in_sectors / 3.0) % 3

	if new_zone != _current_zone:
		_current_zone = new_zone
		_update_background_pattern(new_zone)

func _update_background_pattern(zone_index: int) -> void:
	var target_grid_size: float = 50.0
	var target_scan_speed: float = 0.02
	var zone_name: String = ""
	
	match zone_index:
		0: # The Cache
			target_grid_size = 50.0
			target_scan_speed = 0.02
			zone_name = "THE_CACHE"
		1: # The Stack
			target_grid_size = 80.0
			target_scan_speed = 0.05
			zone_name = "THE_STACK"
		2: # The Bus
			target_grid_size = 30.0
			target_scan_speed = 0.1
			zone_name = "THE_BUS"
	
	print("Entering Zone: ", zone_name)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Transition grid size
	var current_grid = shader_rect.material.get_shader_parameter("grid_size")
	tween.tween_method(func(v: float): 
		shader_rect.material.set_shader_parameter("grid_size", v),
		current_grid, target_grid_size, 2.0)
		
	# Transition scan speed
	var current_speed = shader_rect.material.get_shader_parameter("scanline_speed")
	tween.tween_method(func(v: float): 
		shader_rect.material.set_shader_parameter("scanline_speed", v),
		current_speed, target_scan_speed, 2.0)
