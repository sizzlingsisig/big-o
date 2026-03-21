extends CanvasLayer

## Synchronizes the background shader and labels with the active camera.

@onready var shader_rect: ColorRect = $ShaderRect
@onready var labels_control: Control = $Labels

var _progression_manager: Node = null

func _process(_delta: float) -> void:
	if not _progression_manager:
		_progression_manager = get_tree().get_first_node_in_group("progression_manager")
		if _progression_manager:
			_progression_manager.milestone_reached.connect(_on_milestone_reached)
			print("BackgroundManager: Connected to ProgressionManager")

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
