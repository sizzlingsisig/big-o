extends Area2D
class_name BaseCollectible

## Base class for all collectibles using object pooling and Resource data.

signal collection_ready
signal hover_progress_changed(progress: float)

@export var data: CollectibleData

var _is_active: bool = false
var _is_hovering: bool = false
var _hover_timer: float = 0.0
var _float_tween: Tween

@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var hover_zone: CollisionShape2D = $HoverZone/CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("collectibles")
	_setup_visuals()

func set_data(new_data: CollectibleData) -> void:
	data = new_data
	_setup_visuals()
	if data and data.requires_hover:
		hover_zone.disabled = false
	else:
		hover_zone.disabled = true

func _setup_visuals() -> void:
	if not is_node_ready() or not data:
		return
		
	sprite.play(data.animation_name)
	sprite.scale = data.sprite_scale

func _process(delta: float) -> void:
	if not _is_active:
		return
	
	if _is_hovering and data and data.requires_hover:
		_hover_timer += delta
		
		var player = get_tree().get_first_node_in_group("player")
		if player and player.complexity:
			var required_time = player.complexity.get_hover_time()
			var progress = _hover_timer / required_time
			hover_progress_changed.emit(minf(progress, 1.0))
			
			if _hover_timer >= required_time:
				_trigger_collection(player)

func _physics_process(_delta: float) -> void:
	pass

func _trigger_collection(player: Node2D) -> void:
	if data:
		data.apply_effect(player)
	collection_ready.emit()
	_on_collected()

func activate() -> void:
	_is_active = true
	_hover_timer = 0.0
	_is_hovering = false
	
	if data:
		if data.float_animation:
			_start_floating_animation()
		else:
			sprite.position = Vector2.ZERO
			
		if data.randomize_color:
			sprite.modulate = Color.from_hsv(randf(), randf_range(0.4, 0.8), randf_range(0.8, 1.0))
			sprite.rotation = randf() * TAU
		else:
			sprite.modulate = Color.WHITE
			sprite.rotation = 0.0
	else:
		_start_floating_animation()
		sprite.modulate = Color.WHITE
		sprite.rotation = 0.0
		
	var start_scale = sprite.scale
	sprite.scale = Vector2.ZERO
	create_tween().tween_property(sprite, "scale", start_scale, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _start_floating_animation() -> void:
	if _float_tween:
		_float_tween.kill()
	
	sprite.position = Vector2.ZERO
	_float_tween = create_tween().set_loops()
	_float_tween.tween_property(sprite, "position:y", -10.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_float_tween.tween_property(sprite, "position:y", 10.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func deactivate() -> void:
	_is_active = false
	_is_hovering = false
	_hover_timer = 0.0
	if _float_tween:
		_float_tween.kill()
		_float_tween = null
	if is_instance_valid(CollectiblePool):
		CollectiblePool.return_to_pool(self)

func _on_body_entered(body: Node2D) -> void:
	if not _is_active:
		return
	
	if body is Player:
		if data and data.requires_hover:
			_is_hovering = true
			_hover_timer = 0.0
		else:
			print("[COLLECT] Pickup! Type: ", data.animation_name if data else "unknown")
			_trigger_collection(body)

func _on_body_exited(body: Node2D) -> void:
	if not _is_active:
		return
	
	if body is Player:
		_is_hovering = false
		_hover_timer = 0.0
		hover_progress_changed.emit(0.0)

func _on_collected() -> void:
	deactivate()
