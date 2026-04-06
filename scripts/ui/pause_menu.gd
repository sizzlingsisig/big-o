extends Control
class_name PauseMenu

@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var menu_button: Button = $VBoxContainer/MenuButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	resume_button.mouse_entered.connect(_on_hover)
	menu_button.mouse_entered.connect(_on_hover)
	quit_button.mouse_entered.connect(_on_hover)
	
	# Focus sounds for keyboard/controller navigation
	resume_button.focus_entered.connect(_on_focus_changed)
	menu_button.focus_entered.connect(_on_focus_changed)
	quit_button.focus_entered.connect(_on_focus_changed)
	
	visible = false

func _on_focus_changed() -> void:
	var sm = get_node_or_null("/root/SoundManager")
	if sm:
		sm.play_menu_hover()

func _on_hover() -> void:
	var sm = get_node_or_null("/root/SoundManager")
	if sm:
		sm.play_menu_hover()

func _on_resume_pressed() -> void:
	_play_select_sound()
	hide_pause_menu()

func _on_menu_pressed() -> void:
	_play_select_sound()
	get_tree().paused = false  # Unpause before changing scenes
	GameEvents.game_state_requested.emit(BigOConstants.STATE_MENU)

func _on_quit_pressed() -> void:
	_play_select_sound()
	get_tree().quit()

func _play_select_sound() -> void:
	var sm = get_node_or_null("/root/SoundManager")
	if sm:
		sm.play_menu_select()

func show_pause_menu() -> void:
	visible = true
	get_tree().paused = true

func hide_pause_menu() -> void:
	visible = false
	get_tree().paused = false
