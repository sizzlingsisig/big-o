extends Area2D
class_name BaseCollectible

## Base class for all collectibles using object pooling and Resource data.

@export var data: CollectibleData

var _is_active: bool = false
var _float_tween: Tween

@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("collectibles")
	_setup_visuals()

func set_data(new_data: CollectibleData) -> void:
	data = new_data
	_setup_visuals()

func _setup_visuals() -> void:
	if not is_node_ready() or not data:
		return
		
	sprite.play(data.animation_name)
	sprite.scale = data.sprite_scale

func activate() -> void:
	_is_active = true
	
	if data:
		if data.float_animation:
			_start_floating_animation()
		else:
			sprite.position = Vector2.ZERO
			
		if data.randomize_color:
			# Agar.io style pastel/bright random colors
			sprite.modulate = Color.from_hsv(randf(), randf_range(0.4, 0.8), randf_range(0.8, 1.0))
			sprite.rotation = randf() * TAU
		else:
			sprite.modulate = Color.WHITE
			sprite.rotation = 0.0
	else:
		_start_floating_animation()
		sprite.modulate = Color.WHITE
		sprite.rotation = 0.0
		
	# Quick little scale-in tween so they "pop" into existence
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
	if _float_tween:
		_float_tween.kill()
		_float_tween = null
	if is_instance_valid(CollectiblePool):
		CollectiblePool.return_to_pool(self)

func _on_body_entered(body: Node2D) -> void:
	if not _is_active:
		return
	if body is Player:
		if data:
			data.apply_effect(body)
		_on_collected()

func _on_collected() -> void:
	deactivate()
