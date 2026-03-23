extends Control
class_name PauseMenu

@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var menu_button: Button = $VBoxContainer/MenuButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	visible = false

func _on_resume_pressed() -> void:
	hide_pause_menu()

func _on_menu_pressed() -> void:
	get_tree().paused = false  # Unpause before changing scenes
	GameEvents.game_state_requested.emit("menu")

func _on_quit_pressed() -> void:
	get_tree().quit()

func show_pause_menu() -> void:
	visible = true
	get_tree().paused = true

func hide_pause_menu() -> void:
	visible = false
	get_tree().paused = false
